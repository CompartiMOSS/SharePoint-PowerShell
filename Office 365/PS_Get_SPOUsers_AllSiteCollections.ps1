############################################################################################################################################
# Script that allows to get all the users for all the Site Collections in a SharePoint Online Tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the site collections information in a SharePoint Online tenant
function Get-SPOUsersAllSiteCollections
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
            Write-Host "Users for " $spoSite.Url -foregroundcolor Blue
            Get-SPOUser -Site $spoSite.Url
            Write-Host
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

Get-SPOUsersAllSiteCollections -sUserName $sUserName -sMessage $sMessage



