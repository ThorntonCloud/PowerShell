# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

# Define CSV file path
$CSVPath = "C:\temp\Users.csv"

# Define log file
$LogFile = "C:\temp\logs\AD-UserUpdate.log"

# Function to log messages
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Store the data from Users.csv in the $ADUsers variable
$ADUsers = Import-Csv -Path $CSVPath

foreach ($User in $ADUsers) {
    try {
        # Get existing user from AD
        $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$($User.username)'" -Properties * -ErrorAction SilentlyContinue

        if ($ExistingUser) {
            $Changes = @{}

            # Define parameters for updating
            $UserParams = @{
                SamAccountName = $User.username
            }

            # Loop through eac hattribute to compare and log changes
            $FieldsToUpdate = @{
                Name          = "$($User.firstname) $($User.lastname)"
                GivenName     = $User.firstname
                Surname       = $User.lastname
                Initials      = $User.initials
                DisplayName   = "$($User.firstname) $($User.lastname)"
                City          = $User.city
                PostalCode    = $User.zipcode
                Country       = $User.country
                Company       = $User.company
                State         = $User.state
                StreetAddress = $User.streetaddress
                OfficePhone   = $User.telephone
                EmailAddress  = $User.email
                Title         = $User.jobtitle
                Department    = $User.department
            }

            foreach ($Field in $FieldsToUpdate.Keys) {
                $NewValue = $FieldsToUpdate[$Field]
                $OldValue = $ExistingUser.$Field

                # Check if value needs updating
                if ($NewValue -and ($OldValue -ne $NewValue)) {
                    $UserParams[$Field] = $NewValue
                    $Changes[$Field] = "Changed $Field from '$OldValue' to '$NewValue'"
                }
            }

            if ($Changes.Count -gt 0) {
                Set-ADUser $User.username @UserParams

                Write-Host "Updated $($User.username): $($Changes.Values -join ', ')" -ForegroundColor Green
                Write-Log "Updated $($User.username): $($Changes.Values -join ', ')"
            }
            else {
                Write-Host "No changes needed for $($User.username)." -ForegroundColor Yello
            }
        }
        else {
            Write-Host "User $($User.username) not found in AD." -ForegroundColor Red
            Write-Log "User $($User.username) not found in AD."
        }
    }
    catch {
        Write-Host "Failed to update $($User.username) - $_" -ForegroundColor Red
        Write-Log "Failed to update $($User.username) - $_"
    }
}
