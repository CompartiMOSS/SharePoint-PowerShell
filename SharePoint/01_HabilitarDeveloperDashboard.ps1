############################################################################################################################################
# Script para configurar el panel del desarrollador
# Parámetros necesarios: 
#    ->$sDeveloperDashboardOption: Opción de configuración del panel del desarrollador.
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Definición de la función que configura el panel del desarrollador
function Configure-DeveloperDashboard
{
    param ($sDeveloperDashboardOption)
    try
    {
        write-Host "Configurando el panel del desarrollador en modo $sDeveloperDashboardOption" -ForegroundColor Blue
        $svc=[Microsoft.SharePoint.Administration.SPWebService]::ContentService  
        $ddsetting=$svc.DeveloperDashboardSettings  
        $ddsetting.DisplayLevel=[Microsoft.SharePoint.Administration.SPDeveloperDashboardLevel]::$sDeveloperDashboardOption  
        $ddsetting.Update()    
        Write-Host "Panel del desarrollador configurado en modo " $svc.DeveloperDashboardSettings.DisplayLevel -ForegroundColor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
Configure-DeveloperDashboard -sDeveloperDashboardOption Off
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell

