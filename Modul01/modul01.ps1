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

## AD Objekte umbenennen
Rename-ADObject -Identity "CN=Hans.Tester,DC=ith-ml35,DC=local" -NewName "Hans.Entwickler"

###### Gruppen in der AD
# Neue Gruppen 
New-ADGroup -Name HelpDesk -Path "OU=Groups,OU=ITH,DC=ith-ml35,DC=local" -GroupScope Global

# Nutzer einer Gruppe zuweisen
Add-ADGroupMember "HelpDesk" -Members "Michael.Lindner"

# Gruppenmitgliedschaft ansehen
Get-ADGroupMember HelpDesk

# Gruppenmitgliedschaft aus Usersicht
Get-ADPrincipalGroupMembership "Michael.Lindner" | Select-Object -Property Name

# Computerobjekte
Get-ADComputer -Properties -Description -filter *

# Computer anlegen
New-ADComputer "ITH-MGM05" -Path "OU=Computers,OU=ITH,DC=ith-ml35,DC=local" -Enabled $false

Get-ADComputer "ITH-MGM05" | Set-ADComputer -Enabled $true -Description "Testcomputer"

### AD Papierkorbfunktion prüfen
Get-ADOptionalFeature -Identity 'Recycle Bin Feature'
### Domainname des Members bestimmen
(Get-ADForest).Name
### Aktivieren des AD Papierkorbs
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet `
-Target (Get-ADForest).Name

# Anzeigengelöschter ADObjekte
Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects

# Contakt erstellen und löschen
New-ADObject "Testkontakt zum löschen" -Type contact
Get-ADObject  -Filter "ObjectClass -like 'contact'"
Remove-ADObject "CN=Testkontakt zum löschen,DC=ith-ml35,DC=local"
# Wiederherstellen eines gelöschten Objektes
Restore-ADObject -Identity "CN=Testkontakt zum löschen\0ADEL:9ca17daf-d910-4366-b253-ad885a3e08ff,CN=Deleted Objects,DC=ith-ml35,DC=local"

######## Netzwerkbefehle im Zusammenhang mit AD
# Ping zum Domaincntroller
Test-Connection ith-ad35
# Netzwekkonfiguration ansehen
Get-NetIPConfiguration
# Neue IP Adresse
New-NetIPAddress -InterfaceAlias Intern -IPAddress 172.16.0.2 -PrefixLength 16
Remove-NetIPAddress -InterfaceAlias Intern -IPAddress 172.16.0.2

Set-DnsClientServerAddress -InterfaceAlias intern -ServerAddresses 192.168.115.1,9.9.9.9