#########################################################
# Parameters: Change these as needed
#########################################################
$filePath = "D:\Path\to\audit"
$outputCsv = "C:\path\to\csv"


#########################################################
# Logic
#########################################################
$results = Get-ChildItem -Path $filePath -Directory | ForEach-Object {
    $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum).Sum

    [PSCustomObject]@{
        Company = $_.Name
        Path    = $_.FullName
        SizeGB  = [math]::Round($size / 1GB, 2)
    }
}


#########################################################
# Output: Comment/Uncomment as needed
#########################################################
# Display results in console
# $results |
#    Sort-Object SizeGB -Descending |
#    Format-Table Company, Path, SizeGB -AutoSize

# Save to Csv
$results |
    Sort-Object SizeGB -Descending |
    Export-Csv -Path $outputCsv -NoTypeInformation
Write-Host "Results exported to $outputCsv"
