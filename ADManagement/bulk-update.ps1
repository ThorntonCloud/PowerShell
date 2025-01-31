# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

# Store the data from Users.csv in the $ADUsers variable
$ADUsers = Import-Csv "C:\temp\Users.csv"

foreach ($User in $ADUsers) {
    try {
        $UserParams = @{
            SamAccountName        = $User.username
            Name                  = "$($User.firstname) $($User.lastname)"
            GivenName             = $User.firstname
            Surname               = $User.lastname
            Initial               = $User.initials
            DisplayName           = "$($User.firstname) $($User.lastname)"
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
        }
        if (Get-ADUser -Filter "SamAccountName -eq '$($User.username)'") {
            Set-ADUser @UserParams

            Write-Host "User $($User.username) has been successfully updated." -ForegroundColor Green
        }
        else {
            Write-Host "User $($User.username) does not exist in Active Directory." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to update user $($User.username) - $_" -ForegroundColor Red
    }
}
