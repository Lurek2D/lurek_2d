param(
    [string]$PythonRoot = "C:\Program Files\Python314",
    [switch]$UserOnly = $true
)

$ErrorActionPreference = "Stop"

function Get-PathParts([string]$PathValue) {
    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return @()
    }

    return $PathValue.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" }
}

function Add-UniquePathPart([System.Collections.Generic.List[string]]$Parts, [string]$Part) {
    if (-not $Parts.Contains($Part)) {
        [void]$Parts.Add($Part)
    }
}

function Prepend-UniquePathPart([System.Collections.Generic.List[string]]$Parts, [string]$Part) {
    $filtered = [System.Collections.Generic.List[string]]::new()
    foreach ($existing in $Parts) {
        if ($existing -ne $Part) {
            [void]$filtered.Add($existing)
        }
    }

    $Parts.Clear()
    [void]$Parts.Add($Part)
    foreach ($existing in $filtered) {
        [void]$Parts.Add($existing)
    }
}

if (-not (Test-Path (Join-Path $PythonRoot "python.exe"))) {
    throw "python.exe not found under $PythonRoot"
}

$scriptsDir = Join-Path $PythonRoot "Scripts"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$userParts = [System.Collections.Generic.List[string]]::new()
foreach ($part in Get-PathParts $userPath) {
    [void]$userParts.Add($part)
}

if (Test-Path $scriptsDir) {
    Prepend-UniquePathPart $userParts $scriptsDir
}
Prepend-UniquePathPart $userParts $PythonRoot

$newUserPath = ($userParts -join ";")
[Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")

# Refresh the current process PATH so commands in the same terminal can use python immediately.
$processParts = [System.Collections.Generic.List[string]]::new()
foreach ($part in Get-PathParts $env:Path) {
    [void]$processParts.Add($part)
}

if (Test-Path $scriptsDir) {
    Prepend-UniquePathPart $processParts $scriptsDir
}
Prepend-UniquePathPart $processParts $PythonRoot
$env:Path = ($processParts -join ";")

Write-Host "Updated user PATH with:"
Write-Host "  $PythonRoot"
if (Test-Path $scriptsDir) {
    Write-Host "  $scriptsDir"
}
Write-Host "python now resolves as:"
& python --version
