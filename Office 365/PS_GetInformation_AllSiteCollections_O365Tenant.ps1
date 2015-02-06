############################################################################################################################################
# Script that allows to read the information available for all the Site Collections in an SharePoint Online Tenant.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the site collections information in a SharePoint Online tenant
function Get-SPOSiteCollectionsInfo
{
    param ($sUserName,$sMessage)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the information for all the site colletions in the Office 365 tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        #$msolcred = get-credential -UserName $sUserName -Message $sMessage
        #Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred
        $spoSites=Get-SPOSite | Select *
        foreach($spoSite in $spoSites)
        {
            $spoSite
        }        
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="<YourOffice365Account>"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<YourDomain>-admin.sharepoint.com/"

Get-SPOSiteCollectionsInfo -sUserName $sUserName -sMessage $sMessage



