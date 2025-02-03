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
