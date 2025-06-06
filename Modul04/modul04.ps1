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

$user =Get-ADObject -Filter "ObjectClass -eq 'user'" -SearchBase $targetpath
$user| Remove-ADObject -Confirm:$true

### Suche in der AD
Search-ADAccount -UsersOnly -AccountInactive -SearchBase $targetpath
## Deaktivierte User löschen
$user =Search-ADAccount -UsersOnly -AccountInactive -SearchBase $targetpath
$user| Remove-ADObject -Confirm:$true

### Nach inaktivität suchen
Search-ADAccount -UsersOnly -AccountDisabled  | Get-ADUser -Properties LastLogOnDate| Sort-Object LastLogOnDate | Select-Object Name,LastLogOnDate,Title,DistinguishedName