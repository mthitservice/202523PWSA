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

## Klassenraum anlegen
# Eingangswerte
# Anzahl User
# EinstigsOU
# Optional statisches Passwort
# Optional Passwort Länge
# Optional Mail an User
# Optional Mailbetreff
function New-ClassRoom{


}

## Klassenraum entfernen
function Remove-ClassRoom{

    
}
## Nutzer Importieren
# Eingangswerte Klassenraum
# Pfad zur CSV
function Import-ClassRoomUser{

    
}


## Eventfunction Nutzer deaktivieren die sich längere Zeit nicht angemeldet haben
function Disable-ClassRoomUserInactive{

    
}

Export-ModuleMember -Function New-ClassRoom,Remove-ClassRoom,Import-ClassRoomUser,Disable-ClassRoomUserInactive
