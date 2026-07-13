#Requires -Version 5.1
<#
.SYNOPSIS
    Build and package Lurek2D for Windows distribution.

.DESCRIPTION
    Runs a release build, then assembles a portable distribution folder and
    ZIP archive for end users. The packager enforces a Windows binary size
    budget after UPX compression:

      - ideal: <= 10 MB
      - acceptable: <= 12.5 MB
      - hard max: <= 15 MB

    The script uses the accepted Windows shipping setting: UPX `--best`.

.PARAMETER OutDir
    Root output folder. Default: dist/ inside the workspace.

.PARAMETER SkipBuild
    Skip the release build step and package the existing binary.

.EXAMPLE
    .\tools\dist.ps1
    .\tools\dist.ps1 -SkipBuild
    .\tools\dist.ps1 -OutDir "C:\releases"
#>

param(
    [string]$OutDir = "",
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$WorkspaceRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $OutDir) { $OutDir = Join-Path $WorkspaceRoot 'dist' }

$CargoToml = Join-Path $WorkspaceRoot 'Cargo.toml'
$Version = (Select-String -Path $CargoToml -Pattern '^version\s*=\s*"([^"]+)"' | Select-Object -First 1).Matches.Groups[1].Value
if (-not $Version) { $Version = "1.0.0" }

$ArchName = "lurek2d-windows-x86_64"
$PackageDir = Join-Path $OutDir $ArchName
$ZipPath = Join-Path $OutDir "$ArchName.zip"
$ConsoleBinarySource = Join-Path $WorkspaceRoot 'build\release\lurek2d.exe'
$GuiBinarySource = Join-Path $WorkspaceRoot 'build\release\lurekc.exe'

$IdealBinarySizeMB = 10.0
$AcceptableBinarySizeMB = 12.5
$HardMaxBinarySizeMB = 15.0

function Write-Step([string]$Msg) { Write-Host "[dist] $Msg" -ForegroundColor Cyan }
function Write-OK([string]$Msg) { Write-Host "[ OK ] $Msg" -ForegroundColor Green }
function Write-Warn([string]$Msg) { Write-Host "[warn] $Msg" -ForegroundColor Yellow }
function Write-Fail([string]$Msg) { Write-Host "[FAIL] $Msg" -ForegroundColor Red; exit 1 }

function Resolve-UpxPath {
    $upxCmd = Get-Command upx -ErrorAction SilentlyContinue
    if ($upxCmd) { return $upxCmd.Source }

    $scoopShim = Join-Path $env:USERPROFILE 'scoop\shims\upx.exe'
    if (Test-Path $scoopShim) { return $scoopShim }

    return $null
}

function Get-FileSizeMB([string]$Path) {
    return [math]::Round((Get-Item $Path).Length / 1MB, 2)
}

function Compress-WithUpx([string]$UpxPath, [string]$BinaryPath, [string[]]$Args) {
    $quotedUpx = '"' + $UpxPath + '"'
    $quotedBinary = '"' + $BinaryPath + '"'
    $argText = ($Args -join ' ')

    $compressOutput = cmd.exe /d /c "$quotedUpx $argText $quotedBinary 2>&1"
    $compressOutput | ForEach-Object { Write-Host "    $_" }
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-Path $CargoToml)) {
    Write-Fail "Must be run from the lurek2d workspace root."
}

Write-Step "Checking branding assets ..."
$SplashPng = Join-Path $WorkspaceRoot 'assets\splash.png'
$FaviconIco = Join-Path $WorkspaceRoot 'assets\favicon.ico'
if (-not (Test-Path $SplashPng)) {
    Write-Warn "Missing assets\splash.png."
}
if (-not (Test-Path $FaviconIco)) {
    Write-Warn "Missing assets\favicon.ico."
}

if (-not $SkipBuild) {
    Write-Step "Building Lurek2D (release -- distribution-optimised) -- this may take several minutes ..."
    Push-Location $WorkspaceRoot
    try {
        python tools/dev/parallel_cargo.py build release
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "parallel_cargo.py build release failed (exit $LASTEXITCODE)."
        }
    }
    finally {
        Pop-Location
    }
    Write-OK "Build succeeded."
}
else {
    Write-Step "Skipping build (--SkipBuild set)."
}

if (-not (Test-Path $ConsoleBinarySource)) {
    Write-Fail "Console binary not found at '$ConsoleBinarySource'. Run without -SkipBuild."
}
if (-not (Test-Path $GuiBinarySource)) {
    Write-Fail "GUI binary not found at '$GuiBinarySource'. Run without -SkipBuild."
}

Write-Step "Assembling distribution package at '$PackageDir' ..."
if (Test-Path $PackageDir) { Remove-Item $PackageDir -Recurse -Force }
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

$DestBinary = Join-Path $PackageDir 'lurek2d.exe'
Copy-Item $ConsoleBinarySource -Destination $DestBinary -Force
$SizeBefore = Get-FileSizeMB $DestBinary
$FinalBinarySizeMB = $SizeBefore
Write-OK ("Copied lurek2d.exe ({0} MB)" -f $SizeBefore)

$upxPath = Resolve-UpxPath
if ($upxPath) {
    Copy-Item $ConsoleBinarySource -Destination $DestBinary -Force
    Write-Step "UPX mode 'best' ..."
    if (Compress-WithUpx $upxPath $DestBinary @("--best")) {
        $FinalBinarySizeMB = Get-FileSizeMB $DestBinary
        Write-OK ("UPX compressed (best): {0} MB -> {1} MB" -f $SizeBefore, $FinalBinarySizeMB)
    }
    else {
        Write-Warn "UPX mode 'best' failed; keeping the uncompressed release binary."
    }
}
else {
    Write-Warn "UPX not found on PATH -- skipping compression (add upx to PATH to enable)."
}

$DestGuiBinary = Join-Path $PackageDir 'lurekc.exe'
Copy-Item $GuiBinarySource -Destination $DestGuiBinary -Force
Write-OK ("Copied lurekc.exe ({0} MB)" -f (Get-FileSizeMB $DestGuiBinary))

if ($FinalBinarySizeMB -le $IdealBinarySizeMB) {
    Write-OK ("Final binary size {0} MB meets the ideal <= {1} MB target." -f $FinalBinarySizeMB, $IdealBinarySizeMB)
}
elseif ($FinalBinarySizeMB -le $AcceptableBinarySizeMB) {
    Write-OK ("Final binary size {0} MB is above the ideal {1} MB target but within the acceptable <= {2} MB budget." -f $FinalBinarySizeMB, $IdealBinarySizeMB, $AcceptableBinarySizeMB)
}
elseif ($FinalBinarySizeMB -le $HardMaxBinarySizeMB) {
    Write-Warn ("Final binary size {0} MB exceeds the acceptable {1} MB budget and should be reduced further." -f $FinalBinarySizeMB, $AcceptableBinarySizeMB)
}
else {
    Write-Fail ("Final binary size {0} MB exceeds the hard maximum {1} MB budget." -f $FinalBinarySizeMB, $HardMaxBinarySizeMB)
}

$AssetsSource = Join-Path $WorkspaceRoot 'assets'
if (Test-Path $AssetsSource) {
    $AssetsDest = Join-Path $PackageDir 'assets'
    if (Test-Path $AssetsDest) { Remove-Item $AssetsDest -Recurse -Force }
    Copy-Item $AssetsSource -Destination $AssetsDest -Recurse -Force
    Write-OK "Copied assets/"
}

$ExamplesSource = Join-Path $WorkspaceRoot 'content\examples'
if (Test-Path $ExamplesSource) {
    $ExamplesDest = Join-Path $PackageDir 'examples'
    if (Test-Path $ExamplesDest) { Remove-Item $ExamplesDest -Recurse -Force }
    Copy-Item $ExamplesSource -Destination $ExamplesDest -Recurse -Force
    Write-OK "Copied content/examples/"
}

$DistToolsDest = Join-Path $PackageDir 'tools\dist'
New-Item -ItemType Directory -Path $DistToolsDest -Force | Out-Null
foreach ($toolFile in @('pack.ps1', 'pack.py', 'package_games.py', 'register_lurek_filetype.ps1')) {
    $src = Join-Path $WorkspaceRoot "tools\dist\$toolFile"
    if (Test-Path $src) {
        Copy-Item $src -Destination (Join-Path $DistToolsDest $toolFile) -Force
        Write-OK "Copied tools/dist/$toolFile"
    }
}

$DemosSource = Join-Path $WorkspaceRoot 'content\games'
if (Test-Path $DemosSource) {
    $DemosDest = Join-Path $PackageDir 'games'
    if (Test-Path $DemosDest) { Remove-Item $DemosDest -Recurse -Force }
    Copy-Item $DemosSource -Destination $DemosDest -Recurse -Force
    Write-OK "Copied content/games/"
}

$LibrarySource = Join-Path $WorkspaceRoot 'library'
if (Test-Path $LibrarySource) {
    $LibraryDest = Join-Path $PackageDir 'library'
    if (Test-Path $LibraryDest) { Remove-Item $LibraryDest -Recurse -Force }
    Copy-Item $LibrarySource -Destination $LibraryDest -Recurse -Force
    Write-OK "Copied library/"
}

$ApiDocsDest = Join-Path $PackageDir 'docs'
New-Item -ItemType Directory -Path $ApiDocsDest -Force | Out-Null
foreach ($apiFile in @('lurek.md', 'lurek.lua', 'lureksome.md', 'lureksome.lua')) {
    $src = Join-Path $WorkspaceRoot "docs\api\$apiFile"
    if (Test-Path $src) {
        Copy-Item $src -Destination (Join-Path $ApiDocsDest $apiFile) -Force
        Write-OK "Copied docs/$apiFile"
    }
}

foreach ($f in @('README.md', 'LICENSE')) {
    $src = Join-Path $WorkspaceRoot $f
    if (Test-Path $src) {
        Copy-Item $src -Destination (Join-Path $PackageDir $f) -Force
    }
}

$HowTo = @"
LUREK2D $Version -- Windows Portable Distribution
=================================================

How to run a game
-----------------
  lurek2d.exe  my_game\     (with console window -- for developers)
  lurekc.exe   my_game\     (no console window  -- for end users)
  lurekc.lnk                (shortcut with Lurek2D icon -- drag-drop a game folder)

How to show the splash screen (no game)
----------------------------------------
  lurek2d.exe
  lurekc.exe

Bundled examples
----------------
  examples\   -- single-file API usage scripts (one per lurek.* module)

  Use any example as a starting point:
    lurekc.exe examples\physics

Lureksome standard libraries (library\)
----------------------------------------
  Pure-Lua game modules you can require from your game scripts.
  Available: battle, combat, crafting, economy, inventory, item,
             loot, roguelike, and more.

  Usage in your game:
    local inventory = require("library.inventory")
    local loot      = require("library.loot")

API Reference (docs\)
----------------------
  docs\lurek.md     -- lurek.* Lua API reference (Markdown)
  docs\lurek.lua    -- LuaCATS type stubs for IDE autocompletion
                      (copy to your project root or configure in .luarc.json)
  docs\lureksome.md -- Lureksome library reference (Markdown)
  docs\lureksome.lua -- LuaCATS stubs for bundled library modules

Packaging helpers (tools\dist\)
--------------------------------
  tools\dist\pack.ps1   -- pack a game folder into a .lurek archive
  tools\dist\pack.py    -- cross-platform .lurek packer
  tools\dist\package_games.py -- batch-pack content\games into .lurek files
  tools\dist\register_lurek_filetype.ps1 -- register .lurek double-click handling

Writing your own game
---------------------
  1. Create a folder, e.g. my_game\
  2. Add a main.lua with lurek.load() / lurek.update(dt) / lurek.draw()
  3. Optionally add a conf.lua for window title, width, height
  4. Run: lurekc.exe my_game   (or drag the folder onto lurekc.lnk)

Opening .lurek game archives
----------------------------
  1. Pack your game folder so main.lua is at the ZIP root
  2. Rename or output the archive with a .lurek extension
  3. Run tools\dist\register_lurek_filetype.ps1 once to enable double-click launch
  4. Double-click the .lurek archive or run: lurek2d.exe my_game.lurek

Full docs & source: https://github.com/RandomBladeDude/lurek2d
"@
Set-Content -Path (Join-Path $PackageDir 'HOW-TO-RUN.txt') -Value $HowTo -Encoding UTF8
Write-OK "Written HOW-TO-RUN.txt"

$IcoPath = Join-Path $PackageDir 'assets\favicon.ico'
if (-not (Test-Path $IcoPath)) {
    $IcoPath = Join-Path $PackageDir 'assets\icon.png'
}
if (Test-Path $IcoPath) {
    Write-Step "Creating lurekc.lnk shortcut with Lurek2D icon ..."
    $ws = New-Object -ComObject WScript.Shell
    $lnk = $ws.CreateShortcut((Join-Path $PackageDir 'lurekc.lnk'))
    $lnk.TargetPath = Join-Path $PackageDir 'lurekc.exe'
    $lnk.WorkingDirectory = $PackageDir
    $lnk.IconLocation = "$IcoPath,0"
    $lnk.Description = "Lurek2D -- launch game without console window"
    $lnk.WindowStyle = 1
    $lnk.Save()
    Write-OK "Created lurekc.lnk (double-click to run a game, drag-and-drop supported)"
}

Write-Step "Creating ZIP archive at '$ZipPath' ..."
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $PackageDir,
    $ZipPath,
    [System.IO.Compression.CompressionLevel]::Optimal,
    $true
)
$ZipSizeKB = [math]::Round((Get-Item $ZipPath).Length / 1024)
Write-OK ("ZIP created ({0} KB) -> {1}" -f $ZipSizeKB, $ZipPath)

Write-Host ""
Write-OK "Distribution package ready:"
Write-Host "  Folder : $PackageDir" -ForegroundColor White
Write-Host "  ZIP    : $ZipPath" -ForegroundColor White
Write-Host ""
Write-Host "  Distribute the ZIP or the folder contents to end users." -ForegroundColor Yellow
Write-Host "  For a full installer, run: makensis tools\dist\installer.nsi" -ForegroundColor Yellow
