# Randomize password Function
function Get-RandomPassword {
    Param(
        [Parameter(mandatory = $true)]
        [int]$Length
    )
    Begin {
        if ($Length -lt 14) {
            throw "Password length must be at least 14 characters"
        }
        $Numbers = 1..9
        $LettersLower = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
        $LettersUpper = 'ABCEDEFHIJKLMNOPQRSTUVWXYZ'.ToCharArray()
        $Special = '!@#$%^&*()=+[{}]/?<>'.ToCharArray()

        # For the 4 character types (upper, lower, numerical, and special)
        $N_Count = [math]::Floor($Length * .2)
        $L_Count = [math]::Floor($Length * .4)
        $U_Count = [math]::Floor($Length * .2)
        $S_Count = [math]::Floor($Length * .2)
    }
    Process {
        $Pswrd = $LettersLower | Get-Random -Count $L_Count
        $Pswrd += $Numbers | Get-Random -Count $N_Count
        $Pswrd += $LettersUpper | Get-Random -Count $U_Count
        $Pswrd += $Special | Get-Random -Count $S_Count

        # If the password length isn't long enough (due to rounding), add X special characters
        # Where X is the difference between the desired length and the current length.
        if ($Pswrd.length -lt $Length) {
            $Pswrd += $Special | Get-Random -Count ($Length - $Pswrd.length)
        }

        # Lastly, grab the $Pswrd string and randomize the order
        $Pswrd = ($Pswrd | Get-Random -Count $Length) -join ''
    }
    End {
        $Pswrd
    }
}



# Input users NTID (SAM ACCOUNT NAME)

$User = Read-Host -Prompt 'Input the user logon name for termination (example: jsmith)'



# Input termination ticket number

$Termticket = Read-Host -Prompt 'Input the ticket number in the helpdesk'



# Input termination ticket date

$Termdate = (Get-Date).AddDays(-1).ToString('MM-dd-yyyy')



Write-Host "You input the '$User' with a $Termticket number for the termination date $Termdate" -ForegroundColor red -BackgroundColor white




# Disable-ADAccount -Identity $User

Write-Host "Disabling account" -ForegroundColor red -BackgroundColor white

Disable-ADAccount -Identity $User



# set Description in user-account with ticket and term date

Write-Host "Setting description on users account" -ForegroundColor red -BackgroundColor white

Set-ADUser -Identity $User -Description "Account termination - $Termdate - Ticket number $Termticket"



# Clears out several AD fields to Null



# Company/Department/Description/HomeDirectory/Manager/Office/Scriptpath/physicalDelivertOfficeName

Write-Host "Clearing misc user fields, and groups" -ForegroundColor red -BackgroundColor white



Set-ADUser -Identity $User -Company $Null

Set-ADUser -Identity $User -Department $Null

Set-ADUser -Identity $User -HomeDirectory $Null

Set-ADUser -Identity $User -Manager $Null

Set-ADUser -Identity $User -Office $Null

Set-ADUser -Identity $User -ScriptPath $Null

Set-ADUser -Identity $User -Title $Null

Set-ADUser -Identity $User -OfficePhone $Null



# Move account to Disabled Users OU

Get-ADUser $User | Move-ADObject -TargetPath 'OU=Disabled Users,OU=Users,DC=example,DC=com'


# Remove all other group memberships

Write-host ... $User is member of these AD Groups -fore Yellow

Get-ADPrincipalGroupMembership -Identity $User | Format-Table -Property name

Write-host ...Removing the Group Membership -fore DarkYellow

$ADGroups = Get-ADPrincipalGroupMembership -Identity $User | Where-Object {$_.Name -ne “Domain Users”}

Remove-ADPrincipalGroupMembership -Identity $User -MemberOf $ADGroups -Confirm:$false -verbose

# Change User's Password

$Password = Get-RandomPassword -Length 14

Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString $Password -AsPlainText -Force)