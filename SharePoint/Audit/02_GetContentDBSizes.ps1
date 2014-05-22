############################################################################################################################################
# Script par obtener el tamaño de las BDs de Contenidos
# Parámetros necesarios: N/A
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Definición de la función que obtiene el tamaño de las BD's de contenidos
function Get-ContentDBSizes
{  
    try
    {
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        { 
            #$spWebApp.Name
            $ContentDatabases = $spWebApp.ContentDatabases
            foreach($ContentDatabase in $ContentDatabases) 
            {     
                $ContentDatabaseSize = [Math]::Round(($ContentDatabase.disksizerequired/1GB),2)
                $ContentDatabaseInfo= $spWebApp.DisplayName + "," + $ContentDatabase.Name + "," + $ContentDatabaseSize + " GB" 
                $ContentDatabaseInfo
                #Write-Host " * "  $spWebApp.DisplayName "-" $ContentDatabase.Name ": " $ContentDatabaseSize " GB"
            } 
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
Get-ContentDBSizes > ContentDBs.csv
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell