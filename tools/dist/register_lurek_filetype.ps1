param(
    [string]$EnginePath = "$env:USERPROFILE\bin\lurek.exe",
    [switch]$UsePathLookup,
    [switch]$MachineWide
)

$ErrorActionPreference = "Stop"

function Resolve-EnginePath {
    param([string]$Explicit, [switch]$Lookup)
    if ($Lookup) {
        $cmd = Get-Command lurek -ErrorAction SilentlyContinue
        if ($cmd -and $cmd.Source) { return $cmd.Source }
    }
    return $Explicit
}

$resolved = Resolve-EnginePath -Explicit $EnginePath -Lookup:$UsePathLookup
if (-not (Test-Path $resolved)) {
    throw "lurek.exe not found at: $resolved. Install the engine first (tools/dist/install.ps1) or pass -EnginePath."
}

if ($MachineWide) {
    $root = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes"
} else {
    $root = "Registry::HKEY_CURRENT_USER\Software\Classes"
}

$extKey = Join-Path $root ".lurek"
$progId = "Lurek2D.Game"
$progKey = Join-Path $root $progId
$iconKey = Join-Path $progKey "DefaultIcon"
$cmdKey  = Join-Path $progKey "shell\open\command"

New-Item -Path $extKey -Force | Out-Null
Set-ItemProperty -Path $extKey -Name "(default)" -Value $progId -Force

New-Item -Path $progKey -Force | Out-Null
Set-ItemProperty -Path $progKey -Name "(default)" -Value "Lurek2D Game Archive" -Force

New-Item -Path $iconKey -Force | Out-Null
Set-ItemProperty -Path $iconKey -Name "(default)" -Value "`"$resolved`",0" -Force

New-Item -Path $cmdKey -Force | Out-Null
Set-ItemProperty -Path $cmdKey -Name "(default)" -Value "`"$resolved`" `"%1`"" -Force

Write-Host "Registered .lurek association -> $resolved"
Write-Host "Scope: " ($(if ($MachineWide) { "HKLM (all users)" } else { "HKCU (current user)" }))
Write-Host "You can now double-click .lurek files to open with Lurek2D."
