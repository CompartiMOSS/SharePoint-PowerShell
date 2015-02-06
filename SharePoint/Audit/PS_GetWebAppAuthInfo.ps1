############################################################################################################################################
# Script that gets the authentication type for each web application in a SharePoint farm
# Required Parameters: N/A
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the authentication information for each web application in the farm
function Get-AuthenticationInfo
{  
    try
    {
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        {             
            $settings=$spWebApp.GetIisSettingsWithFallback("Default")
            $spWebApp.DisplayName + ",Claims? " + $spWebApp.UseClaimsAuthentication + ",Authentication Mode: " + $settings.AuthenticationMode
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
Get-AuthenticationInfo > AuthenticationInfo.csv
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell