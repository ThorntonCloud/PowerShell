# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

# Define CSV file path
$CSVPath = "C:\temp\NewUsers.csv"

# Define log file
$LogFile = "C:\temp\logs\AD-UserManagement.log"

# Function to log messages
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Store the data from NewUsers.csv in the $ADUsers variable
$ADUsers = Import-Csv -Path $CSVPath

# Define UPN
$UPN = "thorntoncloud.com"

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {
    try {
        # Define the parameters using a hashtable
        $UserParams = @{
            SamAccountName        = $User.username
            UserPrincipalName     = "$($User.username)@$UPN"
            Name                  = "$($User.firstname) $($User.lastname)"
            GivenName             = $User.firstname
            Surname               = $User.lastname
            Initial               = $User.initials
            Enabled               = $True
            DisplayName           = "$($User.firstname) $($User.lastname)"
            Path                  = $User.ou
            City                  = $User.city
            PostalCode            = $User.zipcode
            Country               = $User.country
            Company               = $User.company
            State                 = $User.state
            StreetAddress         = $User.streetaddress
            OfficePhone           = $User.telephone
            EmailAddress          = $User.email
            Title                 = $User.jobtitle
            Department            = $User.department
            AccountPassword       = (ConvertTo-secureString $User.password -AsPlainText -Force)
            ChangePasswordAtLogon = $True
        }

        # Check to see if the user already exists in AD
        if (Get-ADUser -Filter "SamAccountName -eq '$($User.username)'") {

            # Give a warning if user exists
            Write-Host "A user with username $($User.username) already exists in Active Directory." -ForegroundColor Yellow
            Write-Log "User $($User.username) already exists in Active Directory. Skipping..."
        }
        else {
            # User does not exist then proceed to create the new user account
            New-ADUser @UserParams

            # If user is created, show message.
            Write-Host "The user $($User.username) was created successfully." -ForegroundColor Green
            Write-Log "User $($User.username) created successfully."
        }
    }
    catch {
        # Handle any errors that occur during account creation
        Write-Host "Failed to create user $($User.username) - $_" -ForegroundColor Red
        Write-Log "Error creating user $($User.username): $_"
    }
}