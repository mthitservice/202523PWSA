### Erweiterte AD Funktionen

### Passworthash anlegen und ? Nutzer mit dem Kennwort ausstatten
$usercount=20
$days=5
$ExpirationDate= (Get-Date).AddDays($days);
$userprefix="User"
$targetpath="OU=student,OU=Users,OU=ITH,DC=ith-ml35,DC=local"
$pass="Pa55w.rd" | ConvertTo-SecureString -AsPlainText -Force
$Number=1..$usercount

foreach ($z in $Number)
{
    Write-Host $userprefix$z
    New-ADUser -Name $userprefix$z -Path $targetpath -Enabled $true -ChangePasswordAtLogon $true -AccountPassword $pass -AccountExpirationDate $ExpirationDate
}

# Objekte löschen in bestimmten Bereichen
Get-ADUser -Filter	* -SearchBase $targetpath

# Gruppe hinzufügen
$user =Get-ADObject -Filter "ObjectClass -eq 'user'" -SearchBase $targetpath
$g=New-ADGroup  -name Studenten -Path $targetpath -GroupCategory Security  -GroupScope Global
$g | Add-ADGroupMember -Members $user
# Schüler der Gruppe zuordnen

$user =Get-ADObject -filter "ObjectClass -eq 'user' -or ObjectClass -eq 'group'" -SearchBase $targetpath
$user| Remove-ADObject -Confirm:$true

### Suche in der AD
Search-ADAccount -UsersOnly -AccountInactive -SearchBase $targetpath
## Deaktivierte User löschen
$user =Search-ADAccount -UsersOnly -AccountInactive -SearchBase $targetpath
$user| Remove-ADObject -Confirm:$true

### Nach inaktivität suchen
Search-ADAccount -UsersOnly -AccountDisabled  | Get-ADUser -Properties LastLogOnDate| Sort-Object LastLogOnDate | Select-Object Name,LastLogOnDate,Title,DistinguishedName
### Passwortgenerator

function RandomPasswords {
    # Zwischen 6 und 64 zeichen, Standard 14 Zeichen
    param (
        [ValidateRange(5,64)][int] [INT]$Characters=14
    )
# Mögliche Zeichen
$digitcapital =[char[]](65..90)
$digitsmall =[char[]](97..122)
$numbers =[char[]](48..57)
$special=[char[]](33,35,43,,44,45,46)
$pwstart =(Get-Random -InputObject $digitcapital -Count 1) +(Get-Random -InputObject $digitsmall -Count 1) + (Get-Random -InputObject $numbers -Count 1) +(Get-Random -InputObject $special -Count 1)
$pwrest =ForEach ($i in (0..($Characters-5))) {Get-Random -InputObject ($digitcapital+$digitsmall+$numbers+$special) -Count 1}
$pwrest = $pwrest -join ""
$passwordmixed = Get.Get-Random -InputObject ([char[]]($pwstart+$pwrest)) -Count $Characters
$password=$passwordmixed -join ""
    return $password
}
