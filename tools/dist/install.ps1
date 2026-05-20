#Requires -Version 5.1
<#
.SYNOPSIS
    Install or uninstall the Lurek2D engine locally on Windows.

.DESCRIPTION
    Builds the Lurek2D engine in release mode through tools/dev/parallel_cargo.py,
    copies lurek2d.exe to %USERPROFILE%\bin or a custom destination, copies
    content/games, and registers .lurek archive double-click handling for the
    current user unless -SkipFileAssociation is passed.

.PARAMETER Destination
    Target directory for the binary. Defaults to "$env:USERPROFILE\bin".

.PARAMETER Uninstall
    Remove the installed binary and copied games from Destination.

.PARAMETER SkipFileAssociation
    Skip registering .lurek files with the installed engine binary.

.EXAMPLE
    .\tools\dist\install.ps1
    .\tools\dist\install.ps1 -Destination "C:\Programs\lurek2d"
    .\tools\dist\install.ps1 -Uninstall
#>

param(
    [string]$Destination = "$env:USERPROFILE\bin",
    [switch]$Uninstall,
    [switch]$SkipFileAssociation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BinaryName = 'lurek2d.exe'
$BinaryDest = Join-Path $Destination $BinaryName
$GamesDest = Join-Path $Destination 'games'

function Write-Step([string]$Message) {
    Write-Host "[lurek2d] $Message" -ForegroundColor Cyan
}

function Write-OK([string]$Message) {
    Write-Host "[  OK  ] $Message" -ForegroundColor Green
}

function Write-Fail([string]$Message) {
    Write-Host "[ FAIL ] $Message" -ForegroundColor Red
    exit 1
}

if ($Uninstall) {
    Write-Step "Uninstalling Lurek2D from '$Destination' ..."

    if (Test-Path $BinaryDest) {
        Remove-Item $BinaryDest -Force
        Write-OK "Removed $BinaryDest"
    } else {
        Write-Host "[  --  ] Binary not found at $BinaryDest"
    }

    if (Test-Path $GamesDest) {
        Remove-Item $GamesDest -Recurse -Force
        Write-OK "Removed $GamesDest"
    } else {
        Write-Host "[  --  ] Games folder not found at $GamesDest"
    }

    Write-OK "Uninstall complete."
    exit 0
}

$WorkspaceRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$CargoToml = Join-Path $WorkspaceRoot 'Cargo.toml'
if (-not (Test-Path $CargoToml)) {
    Write-Fail "Cannot find Cargo.toml. Run this script from the Lurek2D workspace."
}

Write-Step "Building Lurek2D release binary."
Push-Location $WorkspaceRoot
try {
    python tools/dev/parallel_cargo.py build release 2>&1 | ForEach-Object { Write-Host "    $_" }
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "parallel_cargo.py build release failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}
Write-OK "Build succeeded."

$BuiltBinary = Join-Path $WorkspaceRoot 'build\release\lurek2d.exe'
if (-not (Test-Path $BuiltBinary)) {
    Write-Fail "Expected binary at '$BuiltBinary' but it was not found."
}

if (-not (Test-Path $Destination)) {
    Write-Step "Creating destination directory '$Destination'."
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Write-OK "Directory created."
}

Write-Step "Installing binary to '$BinaryDest'."
Copy-Item $BuiltBinary -Destination $BinaryDest -Force
Write-OK "Binary installed."

$GamesSource = Join-Path $WorkspaceRoot 'content\games'
if (Test-Path $GamesSource) {
    Write-Step "Copying content/games to '$GamesDest'."
    if (Test-Path $GamesDest) {
        Remove-Item $GamesDest -Recurse -Force
    }
    Copy-Item $GamesSource -Destination $GamesDest -Recurse -Force
    Write-OK "Games copied."
} else {
    Write-Host "[  --  ] content/games folder not found; skipping."
}

if (-not $SkipFileAssociation) {
    $RegisterScript = Join-Path $WorkspaceRoot 'tools\dist\register_lurek_filetype.ps1'
    if (Test-Path $RegisterScript) {
        Write-Step "Registering .lurek archives for '$BinaryDest'."
        & powershell -ExecutionPolicy Bypass -File $RegisterScript -EnginePath $BinaryDest
        if ($LASTEXITCODE -ne 0) {
            Write-Fail ".lurek file association registration failed with exit code $LASTEXITCODE."
        }
        Write-OK ".lurek file association registered for the current user."
    } else {
        Write-Host "[  --  ] register_lurek_filetype.ps1 not found; skipping .lurek association."
    }
}

$PathDirs = $env:PATH -split ';'
if ($Destination -notin $PathDirs) {
    Write-Host ""
    Write-Host "  NOTE: '$Destination' is not in your PATH." -ForegroundColor Yellow
    Write-Host "  Add it to your user PATH to run lurek2d from any terminal:" -ForegroundColor Yellow
    Write-Host "    [System.Environment]::SetEnvironmentVariable('PATH', `$env:PATH + ';$Destination', 'User')" -ForegroundColor DarkYellow
    Write-Host ""
}

Write-OK "Lurek2D installed. Run: lurek2d.exe content\games\showcase\hello_world"
Write-OK "Or use games from: $GamesDest"
