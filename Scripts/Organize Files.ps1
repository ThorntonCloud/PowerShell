# Parameters
$User = "jeremy"
$FilePath = "C:\Users\$Users\Documents"
param([string]$source=$FilePath, [string]$destination="$FilePath\Organized")

# Functions


Function Check-Folder([string]$path, [switch]$create) {

    $exists = Test-Path -Path $path
    
    if (!$exists -and $create) {

        mkdir $path | out-null
        $exists = Test-Path $path

    }


}

Function Display-FolderStats([string]$path) {

    $files = dir $path -Recurse | where {!$_.PSIsContainer}
    $totals = $files | Measure-Object -Property length -Sum
    $stats = "" | Select path,count,size

    $stats.path = $path
    $stats.count = $totals.count
    $stats.size = [math]::Round($totals.sum/1GB,2)
    return $stats
}



# Main Processing

$destExists = Check-Folder -path $destination -create

$files = dir $source -Recurse | where {!$_.PSIsContainer}

foreach ($file in $files) {

    $ext = $file.Extension.Replace(".","")
    $extDestDir = "$destination\$ext"
    
    Check-Folder -path $extDestDir -create

    copy $file.fullname $extDestDir
}