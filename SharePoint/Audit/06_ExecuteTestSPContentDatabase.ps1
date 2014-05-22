############################################################################################################################################
# Script para ejecutar Test-SPContentDatabase contra todas las BDs de Contenidos de la Graja
# Parámetros necesarios: N/A
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Definición de la función que realizar el Test de cada BD de Contenidos de la Granja
function Execute-TestContentDatabase
{  
    param ($sServerInstance)
    try
    {

        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        { 
            #$spWebApp.Name
            $ContentDatabases = $spWebApp.ContentDatabases
            foreach($ContentDatabase in $ContentDatabases) 
            {   
                Test-SPContentDatabase –Name $ContentDatabase.Name -ServerInstance $sServerInstance -WebApplication $spWebApp.Url
            } 
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
Execute-TestContentDatabase -sServerInstance "c4968397007"
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell