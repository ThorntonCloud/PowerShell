$baseFolderPath = "D:\FileRepository\Company"
$CsvPath = "C:\Users\su_jthornton.rpo\Desktop\cleanup.csv"
$folderNames = Import-Csv -Path $CsvPath | Select-Object -ExpandProperty ID
$7ZipPath = "C:\Program Files\7-Zip\7z.exe"
$tempZipPath = "C:\TempZip"
$networkDestination = "\\atl0dd6900.rponline.local\ReleaseArchive\2025-Term\"

if (-not (Test-Path -Path $7ZipPath -PathType Leaf)) {
    throw "7zip file '$7ZipPath' not found"
}

Set-Alias Start-SevenZip $7ZipPath

if (-not (Test-Path -Path $SevenZipPath)) {
    Write-Error "7z.exe not found at $SevenZipPath. Install 7-Zip or update the script."
    exit 1
}

foreach ($folderName in $folderNames) {
    $fullFolderPath = Join-Path -Path $baseFolderPath -ChildPath $folderName

    if (Test-Path -Path $fullFolderPath) {
        $zipFileName = "$folderName.zip"
        $zipFilePath = Join-Path -Path $tempZipPath -ChildPath "$zipFileName"

        try {
            Start-SevenZip a -mx=9 $zipFilePath $fullFolderPath
        } catch {
            Write-Host "Error creating ZIP file for folder $folderName $_" -ForegroundColor Red
            continue
        }

        $networkDestination = "\\atl0dd6900.rponline.local\ReleaseArchive\2025-Term\$zipFileName"
        try {
            Copy-Item -Path $zipFilePath -Destination $networkDestination
        } catch {
            Write-Host "Error copying $zipFileName to network location $_" -ForegroundColor Red
            continue
        }

        try {
            Remove-Item -Path $fullFolderPath -Recurse
            Remove-Item -Path $zipFilePath
        } catch {
            Write-Host "Error deleting original folder $folderName $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Folder $folderName does not exist. Skipping." -ForegroundColor Yellow
    }
}

Write-Host "Job Completed." -ForegroundColor Green
