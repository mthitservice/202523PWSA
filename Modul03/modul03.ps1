# AD Gruppenrichtlinien / Kennwortrichtlinien

# Zeige Gruppenrichtlinien an

Get-GPO -all
Get-GPO -Guid 31b2f340-016d-11d2-945f-00c04fb984f9

# Zeige alle Richtlinien die keine Anwendung finden
$allgpos=Get-GPO -All
foreach ($GP in $allgpos){
    if($GP.Computer.DSVersion -eq 0 -and $GP.User.DSVersion -eq 0)
    {
            Write-Host "Leere GPO:" $GP.DisplayName
    } 

}
### Einen AD GPO Report als XML ausgeben
Get-GPOReport -All -ReportType Xml >> report.xml
Get-GPO -All | %{[XML]$GPOs=Get-GPOReport -Name $_.DisplayName -ReportType Xml;
    $GPOs.Gpo.Name +";" + $GPOs.GPO.LinksTo.SOMName}

#### Neue GPO
$G=New-GPO "ITH-GPO"  -Comment "auf Administrationsgeräten" 
$G.GpoStatus='UserSettingsDisabled'

$PO1=@{
Name ='ITH-GPO'
Key='HKLM\Software\Policies\Microsft\Windows\PowerShell'
ValueName='EnableScripts'
Type='DWord'
Value=1

}
Set-GPRegistryValue @PO1 |Out-Null

Remove-GPO "ITH-GPO"