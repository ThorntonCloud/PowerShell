# Import Active Directory module
Import-Module ActiveDirectory

# Define CSV file path and log file
$CSVPath = "C:\temp\UsersToDisable.csv"
$LogFile = "C:\temp\AD-UserDisable.log"

# Function to log actions
function Write-Log {
    param (
        [string]$Message
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Import CSV file
$ADUsers = Import-Csv -Path $CSVPath

foreach ($User in $ADUsers) {
    try {
        # Get AD user
        $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$($User.username)'" -Properties Enabled -ErrorAction SilentlyContinue

        if ($ExistingUser) {
            if ($ExistingUser.Enabled -eq $false) {
                Write-Host "User $($User.username) is already disabled." -ForegroundColor Yellow
                Write-Log "User $($User.username) is already disabled."
            }
            else {
                # Disable user
                Disable-ADAccount -Identity $ExistingUser.SamAccountName

                Write-Host "User $($User.username) has been disabled." -ForegroundColor Green
                Write-Log "User $($User.username) has been disabled."
            }
        }
        else {
            Write-Host "User $($User.username) not found in Active Directory." -ForegroundColor Red
            Write-Log "User $($User.username) not found in Active Directory."
        }
    }
    catch {
        Write-Host "Failed to disable user $($User.username) - $_" -ForegroundColor Red
        Write-Log "Failed to disable user $($User.username) - $_"
    }
}
