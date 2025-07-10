# README
# The version numbers and paths may need to be updated if this is used again
# in the future, or if it's being reused for a similar use case.

# --- Configurable Variables ---
$computer = "localhost"
$oldVersion = '3.11'
$newVersion = '3.13'
$taskRoot = "\\$computer\c$\Windows\System32\Tasks\RoboFTP Tasks"
$taskNamePrefix = "\RoboFTP Tasks"

$cred = Get-Credential

$oldPathFragment = "-s\s+`"C:\\Program Files \(x86\)\\Robo-FTP $oldVersion\\ProgramData\\Scripts\\(.+?)`""
$newCommand = "C:\Program Files\Robo-FTP $newVersion\Robo-FTP.exe"
$newPathBase = "C:\Program Files\Robo-FTP $newVersion\ProgramData\Scripts\"

# --- Get and Filter Task Files ---
$tasks = Get-ChildItem $taskRoot | Where-Object { -not $_.PSIsContainer }

$updated = 0

foreach ($task in $tasks) {
    try {
        $xmlPath = $task.FullName
        $backupPath = "$xmlPath.bak"

        # Backup original XML
        Copy-Item $xmlPath $backupPath -ErrorAction Stop

        # Load and parse XML
        $xml = [xml](Get-Content -Path $xmlPath)
        $cmd = $xml.Task.Actions.Exec.Command
        $arg = $xml.Task.Actions.Exec.Arguments

        # Check if the command contains the old Robo-FTP executable
        # and the argument contains the old script path format
        if ($cmd -match 'Robo-FTP\.exe' -and $arg -match $oldPathFragment) {
            # Extract the captured script name from the regex match
            $scriptName = $Matches[1]

            # Build the new argument string with the updated script path
            $newArg = "-s `"$([System.IO.Path]::Combine($newPathBase, $scriptName))`""

            # Output details of the change for logging
            Write-Output "Updating: $($task.Name)"
            Write-Output " - Command: $cmd --> $newCommand"
            Write-Output " - Args:    $arg --> $newArg"

            # Update the XML with the new command and argument
            $xml.Task.Actions.Exec.Command = $newCommand
            $xml.Task.Actions.Exec.Arguments = $newArg

            # Save updated XML
            $xml.Save($xmlPath)

            $updated++

            # Delete and Re-register task
            $taskName = [System.IO.Path]::GetFileNameWithoutExtension($task.Name)
            schtasks /delete /tn "$taskNamePrefix\$taskName" /F
            schtasks /create /tn "$taskNamePrefix\$taskName" /ru $cred.Username /rp $cred.GetNetworkCredential().Password /xml $xmlPath
        }
    } catch {
        Write-Warning "Failed to update or register $($task.Name): $_"
    }
}

Write-Output "`nTotal tasks updated and re-registered: $updated"
