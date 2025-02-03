# Get all users from AD, add them to a System.Array() using Username, Email Address, and Password Expiration date as a long date string and given the custom name of "PasswordExpiry"

$users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0} -Properties "SamAccountName", "EmailAddress", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "SamAccountName", "EmailAddress", @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Where-Object {$_.EmailAddress}

# Warning Date Variables
$FourteenDayWarnDate = (Get-Date).AddDays(14).ToLongDateString().ToUpper()
$TenDayWarnDate      = (Get-Date).AddDays(10).ToLongDateString().ToUpper()
$SevenDayWarnDate    = (Get-Date).AddDays(7).ToLongDateString().ToUpper()
$ThreeDayWarnDate    = (Get-Date).AddDays(3).ToLongDateString().ToUpper()
$OneDayWarnDate      = (Get-Date).AddDays(1).ToLongDateString().ToUpper()

# Send-MailMessage parameters Variables
$MailSender = 'Jeremy Thornton <jeremy@thorntoncloud.com>'
$SMTPServer = 'exch01.example.com'

foreach($User in $Users) {
	$PasswordExpiry = $User.PasswordExpiry
	$days = (([datetime]$PasswordExpiry) - (Get-Date)).days
	
	$WarnDate = Switch ($days) {
		14 {$FourteenDayWarnDate}
		10 {$TenDayWarnDate}
		7 {$SevenDayWarnDate}
		3 {$ThreeDayWarnDate}
		1 {$OneDayWarnDate}
	}

	if ($days -in 14, 10, 7, 3, 1) {
		$SamAccount = $user.SamAccountName.ToUpper()
		$Subject    = "Windows Account Password for account $($SamAccount) is about to expire"
		$EmailBody  = @"
					<html> 
					<body> 
					<h1>Your Windows Account password is about to expire</h1> 
					<p>The Windows Account Password for <b>$SamAccount</b> will expire in <b>$days</b> days on <b>$($WarnDate).</b></p>
					<p>If you need assistance changing your password, please submit a ticket.</p> 
					</body> 
					</html>
"@
		$MailSplat = @{
			To          = $User.EmailAddress
			From        = $MailSender
			SmtpServer  = $SMTPServer
			Subject     = $Subject
			BodyAsHTML  = $true
			Body        = $EmailBody
		}
			
		Send-MailMessage @MailSplat
		#Write-Output $EmailBody
	}
}