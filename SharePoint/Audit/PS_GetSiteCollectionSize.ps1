############################################################################################################################################
# Script to determin the storage space used by all the site collections in a SharePoint farm
# Required parameters: N/A
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Function that allows to access to all the Web Applications in the farm
function GetAllWebApplications
{ 
    try
    {
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        {             
            GetAllSitecollectionsInfoInWebapplication -spWebApp $spWebApp  
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
} 

#Function that gets for every site collection in the farm information such storage used, site collection name, tc.  
function GetAllSitecollectionsInfoInWebapplication
{ 
    param ($spWebApp)
    try
    {       
        foreach($spSite in $spWebApp.Sites) 
        {            
            [int]$usage = $spSite.usage.storage/1MB             
            $spWebApp.DisplayName + " , " + $spSite.RootWeb.Title + " , " + $spSite.Url + ", " + $usage + " MB"
        }  
    } 
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
 } 

Start-SPAssignment –Global
GetAllWebApplications > SiteCollection.csv
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell