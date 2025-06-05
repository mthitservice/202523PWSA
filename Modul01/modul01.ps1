# Modul01 AD Grundlagen

# Prüfen welche Module geladen sind
Get-Module
# Hole aktive Modulordner
$env:PSModulePath
# Active DIrectory Module laden
Import-Module ActiveDirectory
Import-Module ServerManager
# Nutzer Benutzer der AD Anzeigen lassen
Get-ADUser -Filter * | Select-Object -Property Name,DistinguishedName
# Erstellen eines Nutzers
New-ADUser -Name "Sandra.Krueger" -City Dresden -Surname "Krüger" -DisplayName "Sandra Krüger" 
-AccountPassword (ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force)
# Generischer Befehl zum erstellen eines Domain Nutzers
New-ADObject -Name "Hans.Tester" -Type contact -DisplayName "Hans Tester(Testaccount)"
# Generisches ANzeigen der AD Objekte
Get-ADObject -Filter "ObjectClass -like 'contact'"
## AD Objekte ändern
Set-ADUser -Identity "CN=Michael.Lindner,OU=Users,OU=ITH,DC=ith-ml35,DC=local" -Description "Administrator der ganzen Geschichte"
Set-ADObject -Identity "CN=Hans.Tester,DC=ith-ml35,DC=local" -Description "Testkontakt"