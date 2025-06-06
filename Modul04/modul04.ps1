### Erweiterte AD Funktionen

### Passworthash anlegen und ? Nutzer mit dem Kennwort ausstatten
$usercount=20
$days=5
$userprefix="User"
$targetpath="OU=student,OU=Users,OU=ITH,DC=ith-ml35,DC=local"
$pass="kennw0rt" | ConvertTo-SecureString -AsPlainText -Force
$Number=1..$usercount

foreach ($z in $Number)
{
    Write-Host $userprefix$z
}