$files = "content/examples/ui.lua", "content/examples/patterns.lua", "content/examples/physics.lua", "content/examples/math.lua", "content/examples/render.lua"
foreach ($file in $files) {
    if (-not (Test-Path $file)) { continue }
    $lines = Get-Content $file
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "--@api-stub:\s*(.+)") {
            $stubName = $matches[1]
            $startI = $i
            $doLine = -1
            for ($j = $i + 1; $j -lt $lines.Length -and $j -le $i + 5; $j++) {
                if ($lines[$j] -match "^\s*do\s*$") {
                    $doLine = $j
                    break
                }
            }
            if ($doLine -ne -1) {
                $endLine = -1
                $depth = 1
                $blockLines = @()
                for ($k = $doLine + 1; $k -lt $lines.Length; $k++) {
                    $l = $lines[$k]
                    if ($l -match "^\s*do\s*$" -or $l -match "\s+do\s*$" -or $l -match "function\(.*\)\s*do") { $depth++ }
                    if ($l -match "^\s*end\s*$") { 
                        $depth-- 
                        if ($depth -eq 0) {
                            $endLine = $k
                            break
                        }
                    }
                    $blockLines += $l
                }
                
                if ($endLine -ne -1) {
                    $nonEmpty = $blockLines | Where-Object { $_.Trim() -ne "" }
                    if ($nonEmpty.Count -gt 5) {
                        Write-Output "FILE: $file"
                        Write-Output "STUB: $stubName"
                        Write-Output "LINES: $($startI + 1)-$($endLine + 1)"
                        Write-Output "COUNT: $($nonEmpty.Count)"
                        Write-Output "TEXT:"
                        Write-Output $lines[$startI..$endLine]
                        Write-Output "----------------------------------------"
                    }
                }
                if ($endLine -ne -1) { $i = $endLine }
            }
        }
    }
}
