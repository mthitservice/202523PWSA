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
