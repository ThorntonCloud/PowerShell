# Prompt Tech for username of account to reset
$User = Read-Host "Enter the employee's username"

# Get current Locked Out status of the user
$LockedOut = (Get-ADUser -Identity $User -Properties *).LockedOut


# Check if the user is locked out
# If True, Unlock
if($LockedOut) {

    Write-Host "The user $User is Locked Out."
    Write-Host "Unlocking Account."
    Write-Host "."
    Write-Host "."
    Write-Host "."
    Write-Host "."

    try {

        Unlock-ADAccount -Identity $User -ErrorAction Stop
        Write-Host "The user $User is now Unlocked."
    
    }
    catch {

        Write-Host "An error occured while unlocking the account. Please make sure you are using your SU account."

    }

} # If False, notify tech
else {

    Write-Host "The user account is not Locked Out."

}

Read-Host "Press ENTER to continue..."