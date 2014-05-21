############################################################################################################################################
# Script que determina el tipo de autenticación de cada aplicación web de la granja
# Parámetros necesarios: N/A
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Definición de la función que obtiene el tamaño de las BD's de contenidos
function Get-AuthenticationInfo
{  
    try
    {
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        {             
            $settings=$spWebApp.GetIisSettingsWithFallback("Default")
            $spWebApp.DisplayName + ", Claims: " + $spWebApp.UseClaimsAuthentication + ",Modo Autentitacación: " + $settings.AuthenticationMode

        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}


Start-SPAssignment –Global
Get-AuthenticationInfo > AuthenticationInfo.csv

Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell