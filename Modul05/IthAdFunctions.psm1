<#
 .DESCRIPTION
 Modul zur Unterstützung von AD Adminaufgaben


#>


##### Hilfsfunktionen
function RandomPasswords {
    # Zwischen 6 und 64 zeichen, Standard 14 Zeichen
    param (
        [ValidateRange(5, 64)][int] [INT]$Characters = 14
    )
    # Mögliche Zeichen
    $digitcapital = [char[]](65..90)
    $digitsmall = [char[]](97..122)
    $numbers = [char[]](48..57)
    $special = [char[]](33, 35, 43, 44, 45, 46)
    $pwstart = (Get-Random -InputObject $digitcapital -Count 1) + (Get-Random -InputObject $digitsmall -Count 1) + (Get-Random -InputObject $numbers -Count 1) + (Get-Random -InputObject $special -Count 1)
    $pwrest = ForEach ($i in (0..($Characters - 5))) { Get-Random -InputObject ($digitcapital + $digitsmall + $numbers + $special) -Count 1 }
    $pwrest = $pwrest -join ""
    $passwordmixed = Get-Random -InputObject ([char[]]($pwstart + $pwrest)) -Count $Characters
    $password = $passwordmixed -join ""
    return $password
}

function GetConfig {
    try {
        $executionPath = $MyInvocation.PSScriptRoot
        $path = $executionPath + '\config.json'
        Write-Debug $path
        $config = Get-Content -Path $path | ConvertFrom-Json
    }
    catch {
        Write-Error "Fehler beim laden der Konfigurationsdatei"
    }
    return $config
}

## Klassenraum anlegen
# Eingangswerte
# Anzahl User
# EinstigsOU
# Optional statisches Passwort
# Optional Passwort Länge
# Optional Mail an User
# Optional Mailbetreff
function New-ClassRoom {
    # Eingangswerte
    [CmdletBinding()]
   
    param(
        [int]$CountUser = [int](GetConfig).'default-usercount',
        [string]$targetOu,
        [string]$ClassName,
        [string]$UserPrefix,
        [string]$password,
        [string]$SmtpServer = (GetConfig).'smtp-server',
        [int]$PasswordLength = [int](GetConfig).'password-length',
        [bool]$MailToUser,
        [string]$MailSubject = ""


    )
    # Anzahl User
    # EinstigsOU
    # Optional statisches Passwort
    # Optional Passwort Länge
    # Optional Mail an User
    # Optional Mailbetreff
    Import-Module ActiveDirectory

    try {
        #Start-Transaction
        ###  Fokus auf OU holen
        $ou = Get-ADOrganizationalUnit $targetOu
        $ou
        ### Nutzer anlegen

        $days = 5
        $ExpirationDate = (Get-Date).AddDays($days);


        $Number = 1..$CountUser
        [System.Collections.ArrayList]$AddedUser =New-Object System.Collections.ArrayList
        foreach ($z in $Number) {
           $pass = 'Pa55w.rd' | ConvertTo-SecureString -AsPlainText -Force
      
            if ($password.Length -gt 4) {
                $pass = $password | ConvertTo-SecureString -AsPlainText -Force
            }
            else
            {
                $pass = RandomPasswords -Characters $PasswordLength | ConvertTo-SecureString -AsPlainText -Force
            }
            Write-Debug $UserPrefix$z
            Write-Host $pass
            $u=New-ADUser -Name $UserPrefix$z -Description $ClassName  -SamAccountName $UserPrefix$z -UserPrincipalName $UserPrefix$z  -Path $targetOu -Enabled $true -ChangePasswordAtLogon $true -AccountPassword $pass -AccountExpirationDate $ExpirationDate -PassThru
           
            $AddedUser.Add($u)
        }
        $AddedUser.Count
        ### Gruppe anlegen

       $g=New-ADGroup  -name $ClassName -Path $targetOu -GroupCategory Security  -GroupScope Global
        ### Nutzer zuordnen
        Write-Information "Send Mail"
        $use =Get-ADObject -Filter "ObjectClass -eq 'user'" -SearchBase $targetOu
        $g | Add-ADGroupMember -Members $use
        ### Nutzer per Mail infornieren
        Write-Information "Send Mail"
       foreach ($us in $AddedUser)
        {
           
           
            Write-Host "Mail an User " $us.Name
            $m=$us.name +'@' + $SmtpServer
            Send-MailMessage -From 'info@xyz.de' -to $m -Subject $MailSubject -Body "Ihr Account wurde eingerichtet" -SmtpServer $SmtpServer
 
        }
        #Use-Transaction
    }
    catch {
        Write-Error "Fehler im Modul"
         Write-Output $_.Exception
        # Undo-Transaction
        <#Do this if a terminating exception happens#>
    }




}

## Klassenraum entfernen
function Remove-ClassRoom {

    
}
## Nutzer Importieren
# Eingangswerte Klassenraum
# Pfad zur CSV
function Import-ClassRoomUser {

    
}


## Eventfunction Nutzer deaktivieren die sich längere Zeit nicht angemeldet haben
function Disable-ClassRoomUserInactive {

    param(
         [string]$targetOu

    )
    $user =Search-ADAccount -UsersOnly -AccountInactive -SearchBase $targetOu
    $user|  Disable-ADAccount
    $logName="Application"
    $source="ITHPOwershellModul"
    $eventId =1001
    $entryType="Information"
    $message="User disabled"
    if (-not [System.Diagnostics.EventLog]::SourceExists($source))
    {
        [System.Diagnostics.EventLog]::CreateEventSource($source,$logName)
    }
    Write-EventLog -LogName $logName -Source $source -EventId $eventId -EntryType $entryType -Message $message
}

Export-ModuleMember -Function New-ClassRoom, Remove-ClassRoom, Import-ClassRoomUser, Disable-ClassRoomUserInactive

# SIG # Begin signature block
# MIIJlgYJKoZIhvcNAQcCoIIJhzCCCYMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIwi88I4nTdNhNObdsEpKwNzC
# Z3ugggb4MIIG9DCCBNygAwIBAgITKAAAAAUvtpG7rMGbUAAAAAAABTANBgkqhkiG
# 9w0BAQwFADBQMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxGDAWBgoJkiaJk/IsZAEZ
# FghpdGgtbWwzNTEdMBsGA1UEAxMUaXRoLW1sMzUtSVRILUFEMzUtQ0EwHhcNMjUw
# NjA2MTMxNzU2WhcNMjYwNjA2MTMxNzU2WjBZMRUwEwYKCZImiZPyLGQBGRYFbG9j
# YWwxGDAWBgoJkiaJk/IsZAEZFghpdGgtbWwzNTEOMAwGA1UEAxMFVXNlcnMxFjAU
# BgNVBAMTDUFkbWluaXN0cmF0b3IwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDa+j39uKxO4Mk1YMLfphkezIHr1tfInyF+44YUTCig8VGOnwADnOw5jbEk
# Mfgg/0SI05Q4GdwzzUmiW8hfi7hxTbxbIQ5uRpDwcyn8zMf7kajUX8lyuNJcVERS
# Tq9cHEc4glt/tai6iCV25N8XEMpIealNzLYBfKyPCa3AoxqvzUr4jSfF4fbHptfI
# kHs66Dj3l6zM2w3pdBtdRamyJVyFW7t+wInU8tESr6PG7/w8jeC0+MyAHudXa1cj
# gC38b1Sn78V7jrC1tmEE/gTZRSN2Kpdkzlv6kVZ96J1Iv5ZG5etHEYsrnIYW0lyP
# OWPTkf8+fHRX33haeKEv0kXZsni9AgMBAAGjggK8MIICuDAlBgkrBgEEAYI3FAIE
# GB4WAEMAbwBkAGUAUwBpAGcAbgBpAG4AZzATBgNVHSUEDDAKBggrBgEFBQcDAzAO
# BgNVHQ8BAf8EBAMCB4AwHQYDVR0OBBYEFPKMg07sFaOTdvtq6JzVL4TkmiWOMB8G
# A1UdIwQYMBaAFMiE1Gk9L293+KSDQtQyDtG0LY1CMIHWBgNVHR8Egc4wgcswgcig
# gcWggcKGgb9sZGFwOi8vL0NOPWl0aC1tbDM1LUlUSC1BRDM1LUNBLENOPUlUSC1B
# RDM1LENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNl
# cyxDTj1Db25maWd1cmF0aW9uLERDPWl0aC1tbDM1LERDPWxvY2FsP2NlcnRpZmlj
# YXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRp
# b25Qb2ludDCByQYIKwYBBQUHAQEEgbwwgbkwgbYGCCsGAQUFBzAChoGpbGRhcDov
# Ly9DTj1pdGgtbWwzNS1JVEgtQUQzNS1DQSxDTj1BSUEsQ049UHVibGljJTIwS2V5
# JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1pdGgt
# bWwzNSxEQz1sb2NhbD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2Vy
# dGlmaWNhdGlvbkF1dGhvcml0eTA3BgNVHREEMDAuoCwGCisGAQQBgjcUAgOgHgwc
# QWRtaW5pc3RyYXRvckBpdGgtbWwzNS5sb2NhbDBMBgkrBgEEAYI3GQIEPzA9oDsG
# CisGAQQBgjcZAgGgLQQrUy0xLTUtMjEtNDIxMDE2MjMwNC0xMzMxNTUyMzItOTkw
# ODg4NDE0LTUwMDANBgkqhkiG9w0BAQwFAAOCAgEANqrspZZDdvX12O1P3WL5BbxW
# sDnZqZ+FR/R4dK4TSo/7NQ95TdjLb0v+HXvnEOwJKnEfP6Odf73flUQXvmPn01Uj
# rVQ+cnmHBk82BUwGvAcVnBsIqfdnfb40XJMw0Cs0ktYgzNZqfsUUnHy6a3df2WLC
# 3yvKKEn/tan/35tX1HOSWS4wekmZ9QS5kJButavbXORLB+NYv/vo2GmoX1dkLm0L
# vgL6mm2AlWrhHHwB5ImKkTkAulrb//16E51AnLo6saYX8k0p5O5x6U7TJSGuCDBr
# 1xidS8ocBU5EpZSnP0zrFPEur2uBr8ku3THnxyZIqql2HP2Xm5EFlcNnPFYj391h
# YOhlTLSsCZERTAyDHl3Cqai4jII3rMmO65N4zQfNynXwlbl5m8JvVcjSCBIQi2do
# BuOC9g4RBYiWA6B9nfVNHPcNIB13wUEIaVWu9tqyd+7lZA8Voh2cfd8RM3zOWSAQ
# RJBy/nNOZhD3mJ1Y4x212wf5PjJBSvwKDBhAhxgGSzDgJM65UJGo72vi0GsGLgzc
# CuT9puTA50PG6EZ2nX3G1AL8fgALKyDMaFZbqn5Mt4a3Fg7iYnnmKtA93kuVaoEI
# WSw431B3VdsWUFW8n4K39efszRqG2/ceTFtVSem/1/uhlEHVM/mN2Qlg3ltJIYvY
# BZA3nZi/ZRFP8iOhR+0xggIIMIICBAIBATBnMFAxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEYMBYGCgmSJomT8ixkARkWCGl0aC1tbDM1MR0wGwYDVQQDExRpdGgtbWwz
# NS1JVEgtQUQzNS1DQQITKAAAAAUvtpG7rMGbUAAAAAAABTAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUl+DPr52c0/YLO55NEQq6mn9IWoIwDQYJKoZIhvcNAQEBBQAEggEAAzNxHW8t
# HaikKrZ5bpj93NuP34078spThxtavx8J0dzY1kWpsHJDCbJ5rRlTNcRv7sKHdpB/
# eWfgNygMt67JOCZzylgU5AKx5ggLByLjp5BYc/2EfhHyUvDOoIYl+gGiND2z/iCX
# N518RF/CSHhSDGIOQuiWmxcZ2Nn+aY4wjalpRADUw3bocJ/jpmIwYteUVNNGklyE
# Qz3MOhmqe+qZMuwQd2umQfnKsctR4YN0SyPNFk4sxAVQQ2l5L7QTkuhTXzKFD2t/
# xTR8DHE22XUG3sufqu/F6tiHZo4Hi6w2Z+eRCy/ljw/ZGUbg//eitAidPDYK26QF
# vlX7b3j4lDVezw==
# SIG # End signature block
