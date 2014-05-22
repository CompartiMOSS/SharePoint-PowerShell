############################################################################################################################################
# Script that allows to configure the SharePoint Developer Dashboard
# Required Parameters: 
#    ->$sDeveloperDashboardOption: Configuration level (On, Off) for the Developer Dashboard).
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that configures the Developer Dashboard
function Configure-DeveloperDashboard
{
    param ($sDeveloperDashboardOption)
    try
    {
        write-Host "Configuring the developer dashboard in mode $sDeveloperDashboardOption" -ForegroundColor Blue
        $svc=[Microsoft.SharePoint.Administration.SPWebService]::ContentService  
        $ddsetting=$svc.DeveloperDashboardSettings  
        $ddsetting.DisplayLevel=[Microsoft.SharePoint.Administration.SPDeveloperDashboardLevel]::$sDeveloperDashboardOption  
        $ddsetting.Update()    
        Write-Host "Developer Dashboard configured in mode " $svc.DeveloperDashboardSettings.DisplayLevel -ForegroundColor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
Configure-DeveloperDashboard -sDeveloperDashboardOption Off
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell