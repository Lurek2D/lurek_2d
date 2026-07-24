#Requires -Version 5.1
<#
.SYNOPSIS
    Full Lurek2D release pipeline: package the optimized release build,
    optionally prebuild debug, build the VS Code extension, and assemble
    GitHub release artifacts.

.DESCRIPTION
    Steps performed:
      1. Optional debug build   -> build/debug/lurek2d.exe
      2. Release build          -> build/release/lurek2d.exe
      3. Portable ZIP           -> dist/lurek2d-windows-x86_64.zip
      4. NSIS installer         -> dist/lurek2d-<version>-setup.exe
      5. VS Code extension      -> dist/lurek2d-toolkit-<version>.vsix
      6. Assemble               -> dist/github-release/

    The default path keeps only two Rust build modes:
      - debug for the fastest local iteration
      - release for end-user distribution and UPX packaging

    Add -IncludeDebugBuild only when you want a fresh fast-run binary before
    the release packaging steps.

    Pass -SkipRustBuilds to reuse existing binaries (useful when only repacking).
    Pass -SkipExtension to skip the VS Code extension build.
    Pass -SkipInstaller to skip NSIS (e.g. if makensis is not installed).

.PARAMETER SkipRustBuilds
    Skip the optional debug build and the default release compilation step.

.PARAMETER IncludeDebugBuild
    Also build the debug profile into build/debug/.

.PARAMETER SkipExtension
    Skip VS Code extension build.

.PARAMETER SkipInstaller
    Skip NSIS installer creation.

.PARAMETER OutDir
    Root output directory. Default: dist/ inside the workspace.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools/dist/release.ps1
    powershell -ExecutionPolicy Bypass -File tools/dist/release.ps1 -IncludeDebugBuild
    powershell -ExecutionPolicy Bypass -File tools/dist/release.ps1 -SkipRustBuilds
    powershell -ExecutionPolicy Bypass -File tools/dist/release.ps1 -SkipInstaller
#>

param(
    [switch]$SkipRustBuilds,
    [switch]$IncludeDebugBuild,
    [switch]$SkipExtension,
    [switch]$SkipInstaller,
    [string]$OutDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$WorkspaceRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$ExtensionRoot = Join-Path (Split-Path $WorkspaceRoot -Parent) "$(Split-Path $WorkspaceRoot -Leaf)_extension"
if (-not $OutDir) { $OutDir = Join-Path $WorkspaceRoot 'dist' }

$CargoToml = Join-Path $WorkspaceRoot 'Cargo.toml'
if (-not (Test-Path $CargoToml)) {
    Write-Error "Cargo.toml not found. Run from the workspace root or tools/dist/."
    exit 1
}

$Version = (Select-String -Path $CargoToml -Pattern '^version\s*=\s*"([^"]+)"' | Select-Object -First 1).Matches.Groups[1].Value
if (-not $Version) { $Version = "1.0.0" }

$ReleaseDir = Join-Path $OutDir 'github-release'

function Write-Step([string]$Msg) { Write-Host "`n[release] $Msg" -ForegroundColor Cyan }
function Write-OK([string]$Msg) { Write-Host "  [ OK ]  $Msg" -ForegroundColor Green }
function Write-Warn([string]$Msg) { Write-Host "  [WARN]  $Msg" -ForegroundColor Yellow }
function Write-Fail([string]$Msg) { Write-Host "  [FAIL]  $Msg" -ForegroundColor Red; exit 1 }

function Invoke-Checked([string]$Command, [string[]]$CmdArgs) {
    & $Command @CmdArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "'$Command $($CmdArgs -join ' ')' exited $LASTEXITCODE"
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Magenta
Write-Host "  Lurek2D $Version - Release Pipeline" -ForegroundColor Magenta
Write-Host "=====================================================" -ForegroundColor Magenta

Push-Location $WorkspaceRoot

try {
    if (-not $SkipRustBuilds -and $IncludeDebugBuild) {
        Write-Step "Optional debug build"
        Invoke-Checked python @('tools/dev/parallel_cargo.py', 'build', 'debug')
        Write-OK "Debug build -> build/debug/lurek2d.exe"
    } elseif ($SkipRustBuilds) {
        Write-Warn "Skipping debug build (-SkipRustBuilds)"
    } else {
        Write-Warn "Skipping debug build (not requested)"
    }

    if (-not $SkipRustBuilds) {
        Write-Step "Release build and portable ZIP"
        $distArgs = @('-ExecutionPolicy', 'Bypass', '-File', 'tools/dist/dist.ps1', '-OutDir', $OutDir)
        Invoke-Checked powershell $distArgs
    } else {
        Write-Step "Repackage only (skip release build)"
        $distArgs = @('-ExecutionPolicy', 'Bypass', '-File', 'tools/dist/dist.ps1', '-SkipBuild', '-OutDir', $OutDir)
        Invoke-Checked powershell $distArgs
    }

    $ZipPath = Join-Path $OutDir 'lurek2d-windows-x86_64.zip'
    if (Test-Path $ZipPath) {
        Write-OK "Portable ZIP -> $ZipPath"
    } else {
        Write-Warn "Expected ZIP not found at $ZipPath"
    }

    $InstallerPath = Join-Path $OutDir "lurek2d-$Version-setup.exe"
    if (-not $SkipInstaller) {
        Write-Step "NSIS Windows installer"
        if (Get-Command makensis -ErrorAction SilentlyContinue) {
            if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
            Invoke-Checked makensis @("/DAPP_VERSION=$Version", 'tools/dist/installer.nsi')
            if (Test-Path $InstallerPath) {
                $sizeMB = [math]::Round((Get-Item $InstallerPath).Length / 1MB, 1)
                Write-OK ("Installer -> {0} ({1} MB)" -f $InstallerPath, $sizeMB)
            }
        } else {
            Write-Warn "makensis not on PATH - skipping installer. Install NSIS: https://nsis.sourceforge.io"
            $SkipInstaller = $true
        }
    } else {
        Write-Warn "Skipping NSIS installer (-SkipInstaller)"
    }

    $ExtVersionRaw = (Get-Content (Join-Path $ExtensionRoot 'vscode/package.json') | ConvertFrom-Json).version
    $VsixName = "lurek2d-toolkit-$ExtVersionRaw.vsix"
    $VsixPath = Join-Path $ExtensionRoot "vscode/$VsixName"
    if (-not $SkipExtension) {
        Write-Step "VS Code extension"
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Push-Location (Join-Path $ExtensionRoot 'vscode')
            try {
                Write-Host "  Installing npm dependencies..."
                Invoke-Checked npm @('install', '--prefer-offline')
                Write-Host "  Building extension..."
                Invoke-Checked npm @('run', 'package')
                $VsixActual = Get-ChildItem -Filter '*.vsix' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                if ($VsixActual) {
                    $VsixPath = $VsixActual.FullName
                    Write-OK "Extension -> $VsixPath"
                }
            } finally {
                Pop-Location
            }
        } else {
            Write-Warn "npm not on PATH - skipping extension build."
            $SkipExtension = $true
        }
    } else {
        Write-Warn "Skipping VS Code extension (-SkipExtension)"
    }

    Write-Step "Assembling GitHub release artifacts"
    if (Test-Path $ReleaseDir) { Remove-Item $ReleaseDir -Recurse -Force }
    New-Item -ItemType Directory -Path $ReleaseDir | Out-Null

    $artifacts = @()

    if (Test-Path $ZipPath) {
        $destZip = Join-Path $ReleaseDir (Split-Path $ZipPath -Leaf)
        Copy-Item $ZipPath $destZip -Force
        $artifacts += $destZip
        Write-OK "Copied portable ZIP"
    }

    if (-not $SkipInstaller -and (Test-Path $InstallerPath)) {
        $destInstaller = Join-Path $ReleaseDir (Split-Path $InstallerPath -Leaf)
        Copy-Item $InstallerPath $destInstaller -Force
        $artifacts += $destInstaller
        Write-OK "Copied Windows installer"
    }

    if (-not $SkipExtension -and (Test-Path $VsixPath)) {
        $destVsix = Join-Path $ReleaseDir (Split-Path $VsixPath -Leaf)
        Copy-Item $VsixPath $destVsix -Force
        $artifacts += $destVsix
        Write-OK "Copied VS Code extension"
    }

    Write-Step "Generating SHA256 checksums"
    $ChecksumFile = Join-Path $ReleaseDir 'checksums-sha256.txt'
    $checksumLines = foreach ($artifact in $artifacts) {
        $hash = (Get-FileHash $artifact -Algorithm SHA256).Hash.ToLower()
        "$hash  $(Split-Path $artifact -Leaf)"
    }
    $checksumLines | Set-Content $ChecksumFile -Encoding UTF8
    Write-OK "Checksums -> $ChecksumFile"

    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Magenta
    Write-Host "  Release artifacts ready for GitHub Releases" -ForegroundColor Green
    Write-Host "  Folder: $ReleaseDir" -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Magenta
    Get-ChildItem $ReleaseDir | Format-Table Name, @{N='Size (KB)';E={[math]::Round($_.Length / 1KB, 1)}} -AutoSize
} finally {
    Pop-Location
}
