# Imports list of Termed users to PS Object
$Users = Import-Csv C:\Temp\Termed.csv

# Checks each user in the list and returns the Status, then appends the PS Object with the result
foreach($User in $Users) {

    $un = $User.Username
    $status = (Get-ADUser -Identity $un -Properties *).Enabled
    $logondate = (Get-ADUser -Identity $un -Properties *).LastLogonDate

    if($status -eq $True) {
        $User.Status = "Enabled"
    }
    else {
        $User.Status = "Disabled"
	$User.LastLogonDate = $logondate

    }

}

# Exports results to a CSV
$Users | Export-Csv C:\Temp\Termed.csv -Append -NoClobber -NoTypeInformation