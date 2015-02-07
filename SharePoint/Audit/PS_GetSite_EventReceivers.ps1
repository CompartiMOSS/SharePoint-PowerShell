############################################################################################################################################
# Script that gets all the event receivers for a SharePoint site
# Required Parameters: 
#    ->$sSiteCollectionUrl: Site Collection Url.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the event receivers for a SharePoint site
function Get-SiteEventReceivers
{
    param ($sSiteCollectionUrl)
    try
    {
        write-Host "Getting all the Event Receivers for $sSiteCollectionUrl" -ForegroundColor Green
        $spsSite = Get-SPSite -Identity $sSiteCollectionUrl
        $spwWeb=$spsSite.OpenWeb()
        $spContentTypes=$spwWeb.ContentTypes
         #We need to iterate through the $spContentTyoes to get the receivers for each Content Type in the site
        foreach($spContentType in $spContentTypes){
            
            Write-Host "Conent Type: " $spContentType.Name -ForegroundColor Green
            if($spContentType.EventReceivers -ne $null)
            {
                $spContentType.EventReceivers |  Select { $_.Assembly, $_.Class, $_.Type } | Format-Table
            }else{
                Write-Host "No Content Types for " $spContentType.Name
            }
            Write-Host "-----------------------------------------------------------"            
        }      
        #$spwWeb.ContentTypes.EventReceivers |  Select { $_.Assembly, $_.Class, $_.Type } | Format-Table
        $spwWeb.Dispose()
        $spsSite.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sSiteCollectionUrl="http://c4968397007/sites/Intranet"
Get-SiteEventReceivers -sSiteCollectionUrl $sSiteCollectionUrl
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell