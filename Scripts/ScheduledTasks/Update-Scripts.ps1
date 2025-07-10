# README
# Each section below is modular, and meant to be run independently.
# Run the first section to update the scripts, saving the new
# scripts with ".updated" in the name. Then, after verifying,
# run the next section to remove the old scripts. Finally,
# run the third section to rename the new scripts to match
# the original name.

#### ----- Update the scripts ----- ####
# Get all files ending in .s from the Robo-FTP 3.13 Scripts directory
Get-ChildItem -Path "C:\Program Files\Robo-FTP 3.13\ProgramData\Scripts" -Filter *.s | ForEach-Object {
    
    try {
        # Read each file's content, perform a regex replacement on a specific UNC-style path
        # Replace '\\atl0util34org\\robo-ftp\' with '\atl0org36util\robo-ftp$'
        # Then write the updated content to a new file with '.updated' appended to the name
        (Get-Content $_.FullName) -replace '\\atl0util34org\\robo-ftp\$', '\atl0org36util\robo-ftp$' |
        Set-Content "$($_.FullName).updated"

        Write-Output "Updated: $($_.Name) -> $($_.Name).updated"
    } catch {
        Write Warning "Failed to process $($_.FullName): $_"
    }
}

#### ----- Delete the old scripts ----- ####
# Get all files with a .s extension in the Robo-FTP 3.13 Scripts directory
Get-ChildItem -Path "C:\Program Files\Robo-FTP 3.13\ProgramData\Scripts" -Filter *.s | ForEach-Object {
    
    try {
        # Delete each file permanently
        Remove-Item -Path $_.FullName # -WhatIf <-- if you want a dry run
        Write-Output "Deleted: $($_.FullName)"
    } catch {
        Write-Warning "Failed to delete $($_.FullName): $_"
    }
}

#### ----- Rename new scripts ----- ####
# Define the directory containing the updated script files
$scriptPath = "C:\Program Files\Robo-FTP 3.13\ProgramData\Scripts"

# Find all files in the directory with the ".s.updated" extension
Get-ChildItem -Path $scriptPath -Filter *.s.updated | ForEach-Object {
    try {
        # Store the full path of the current .s.updated file
        $oldPath = $_.FullName

        # Generate the new name by replacing ".s.updated" with ".s"
        $newName = $_.Name -replace '\.s\.updated$', '.s'

        # Build the full path for the renamed file
        $newPath = Join-Path -Path $_.DirectoryName -ChildPath $newName

        # Check if a file with the target name already exists to avoid overwriting
        if (Test-Path $newPath) {
            Write-Warning "Skipping rename for '$($_.Name)' — target '$newName' already exists."
        } else {
            # Rename the file safely
            Rename-Item -Path $oldPath -NewName $newName
            Write-Output "Renamed: $($_.Name) -> $newName"
        }
    } catch {
        # Log a warning if any error occurs during the rename process
        Write-Warning "Failed to rename $($_.FullName): $_"
    }
}
