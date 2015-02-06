############################################################################################################################################
# Script para creación de elementos de una lista desde un CSV
# Parámetros necesarios: 
#       - URL del sitio
#       - Nombre de la lista
#       - Ruta al fichero CSV
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Definición de la función que lee el CSV y lo carga en la lista
function Add-CsvDataToList() 
{ 
    param($sweb,$slistName,$scsvPath)

    try
    {
        $web = Get-SPWeb -Identity $sweb
        $list = $web.Lists.get_Item($slistName) 
        Import-Csv $scsvPath | ForEach-Object { 
            $csvRow = $_ 
            $newItem = $list.Items.Add() 
            Get-Member -InputObject $csvRow -MemberType NoteProperty | ForEach-Object { 
                $property = $_.Name 

                if ($_.Name -eq "ENMARCHAReceiver")
                {
                    $user = Get-SPUser -Identity $csvRow.$property -web $sweb 
                    $newItem.set_Item($property, $user) 
                } 
                Elseif ($_.Name -eq "ENMARCHASender")
                {
                    $user = Get-SPUser -Identity $csvRow.$property -web $sweb 
                    $newItem.set_Item($property, $user) 
                } 
                Elseif ($_.Name -eq "ENMARCHAUser")
                {
                    $user = Get-SPUser -Identity $csvRow.$property -web $sweb 
                    $newItem.set_Item($property, $user) 
                } 
                Else 
                {
                    $newItem.set_Item($property, $csvRow.$property) 
                }
            } 
            $newItem.Update() 
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}


Start-SPAssignment –Global

$sWebUrl="http://sf1"
$sListName="Notifications"
$sCSVPath="c:\deploy\notifications.csv"

Add-CsvDataToList -sweb $sWebUrl -slistName $sListName -scsvPath $sCSVPath

$sListName="Favorites"
$sCSVPath="c:\deploy\favorites.csv"

Add-CsvDataToList -sweb $sWebUrl -slistName $sListName -scsvPath $sCSVPath

Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell