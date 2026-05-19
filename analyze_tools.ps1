$files = Get-ChildItem -Path tools -Recurse -File | Where-Object { 
    $_.FullName -notmatch "__pycache__" -and 
    $_.Name -ne "README.md" -and 
    $_.FullName -notmatch "baseline\\.*\.json$" 
} | ForEach-Object { $_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\', '/') }

$tempPatterns = "fix_|clean_|merge_|restore_|remove_|strip_|add_clippy_allows|batch\d+|types2|widget_stubs|fix_game_upvalues|fix_poly"

$report = foreach ($file in $files) {
    # Escape for regex if needed, but for simple paths we can use -SimpleMatch
    $refs = Select-String -Path * -Recurse -Pattern $file -Exclude "*.json", "*.md", "__pycache__*" -List | Where-Object { $_.Path -notmatch [regex]::Escape($file.Replace('/', '\')) }
    
    # Check Readmes/Changelog specifically
    $readmeRefs = Select-String -Path "tools\**\README.md", "CHANGELOG.md" -Pattern $file -List
    
    # Filter refs
    $outside = $refs | Where-Object { $_.Path -notmatch "^$(Get-Location.Path)\\tools\\" }
    $inside = $refs | Where-Object { $_.Path -match "^$(Get-Location.Path)\\tools\\" }

    $isTemp = $file -match $tempPatterns

    [PSCustomObject]@{
        File = $file
        OutsideCount = @($outside).Count
        ReadmeCount = @($readmeRefs).Count
        InsideCount = @($inside).Count
        IsTemp = $isTemp
        OutsideNames = (@($outside | ForEach-Object { Split-Path $_.Path -Leaf }) -join ", ")
    }
}

$report | Sort-Object OutsideCount, ReadmeCount | Format-Table -Property File, OutsideCount, ReadmeCount, InsideCount, IsTemp, OutsideNames -AutoSize
