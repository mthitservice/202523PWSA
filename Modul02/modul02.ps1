### Konfiguration Active Directory

$a=Get-NetAdapter 
$a| fl
# DHCP deaktivieren
Set-NetIPInterface -InterfaceAlias ($a[0]).name -AddressFamily IPv4 -Dhcp Disabled -PassThru
# IP Adresse setzen
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias ($a[0]).name -IPAddress 192.168.115.2 -PrefixLength 24 -DefaultGateway 192.168.115.1
# DNS Server einstellen
Set-DnsClientServerAddress -InterfaceAlias ($a[0]).namen -ServerAddresses 192.168.115.1
# IP V6 deaktivieren
Disable-NetAdapterBinding -InterfaceAlias ($a[0]).name -ComponentID ms_tcpip6
#Server umbenennen und Neustart
Rename-Computer -NewName ITH-MGM01 -Restart -Force
############################################
# Installation AD Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
# ADDS Deployment eine DC zur Gesamtstruktur hinzufügen
Import-Module ADDSDeployment
Install-ADDSDomainController  
-DomainName "ith-ml35.local"  
-SiteName "Dresden"  
 -InstallDns:$true     
 -Force:$true  
 -NoGlobalCatalog:$false    
 -CreateDNSDelegation:$false 
 -CriticalReplicationOnly:$false
 -DatabasePath "c:\Windows\NTDS" 
 -LogPath "C:\Windows\NTDS"    
 -NoRebootOnCompletion:$false   
-SysvolPath "c:\windows\SYSVOL"
-SafeModeAdministratorPassword (ConvertTo-SecureString "Pa55w.rd" -AsPlainText -Force)

#################################### Rollenverschiebung
    

Get-ADDomainController -filter * | select-Object -Property HostName,OPerationMasterRoles | Where-Object{$_.OPerationMasterRoles} | Ft -AutoSize

Move-ADDirectoryServerOperationMasterRole -Identity ITH-MGM01 -OperationMasterRole RIDMaster -Confirm:$true
Move-ADDirectoryServerOperationMasterRole -Identity ITH-MGM01 -OperationMasterRole InfrastructureMaster  -Force
Move-ADDirectoryServerOperationMasterRole -Identity ITH-MGM01 -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator -Force

# PDC Emulator (0)RID Pool Manager (1)Infrastruktur Master (2)Domain Naming Master (3)Schema-Master (4)

Move-ADDirectoryServerOperationMasterRole -Identity ITH-AD35 -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator,InfrastructureMaster,RIDMaster -Force



    
