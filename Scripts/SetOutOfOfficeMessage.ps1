# Get username of the Out of Office user
$User = Read-Host "Enter the username of the Out of Office user"

# Get alternative contact info from tect
$ContactEmail = (Read-Host "Enter the email address of the alternative contact")

# Connect to Exchange console and set OOO
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$ExchangeServer/PowerShell
Import-PSSession $Session -DisableNameChecking

try {

    Set-MailboxAutoReplyConfiguration -Identity $User -AutoreplyState Enabled -InternalMessage "I am currently out of the office, and will respond to emails and voicemail when I return. If you require immediate assistance, please reach out to $contactemail."
    Write-Host "The OOO message was set successfully."

}
catch {

    Write-Host "There was an error setting the OOO message."

}
Remove-PSSession $Session

Read-Host "Press ENTER to continue..."
