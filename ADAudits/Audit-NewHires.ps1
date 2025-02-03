# Checks if AD account exists and returns True or False
function Test-ADUser {
  param(
    [Parameter(Mandatory = $true)]
    [String] $sAMAccountName
  )
  $null -ne ([ADSISearcher] "(sAMAccountName=$sAMAccountName)").FindOne()
}

# Imports list of New Hires to PS Object
$Users = Import-Csv C:\Temp\NewHires.csv

# Checks each user in the list against the Test-ADUser function, and appends the PS Object with the result
try {
    foreach($User in $Users) {

        $un = $User.Username
        $wc = (Get-ADUser -Identity $un -Properties *).WhenCreated
        if((Test-ADUser $un) -eq $true) {
            $User.AccountCreated = "True"
            $User.WhenCreated = $wc
        }
        else {
            $User.AccountCreated = "False"
        }

    }
} catch {
    Write-Host "User '$($User.username)' does not exist in active directory - $_"
}

#Export the PS Object with the results to CSV
$Users | Export-Csv C:\Temp\NewHire.csv -Append -NoClobber -NoTypeInformation