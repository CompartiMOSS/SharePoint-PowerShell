############################################################################################################################################
# Script that allows to create a new site collection in SharePoint Online
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
#  -> $sSiteColTitle: Site Collection Title
#  -> $sSiteColUrl: Site Collection Url
#  -> $sOwner: Site Collection Owner
#  -> $iLocaleID: Language ID for the Site Collection
#  -> $sTemplateID: SharePoint Template to create the Site Collection
#  -> $iStorageQuota: Site Collection Storage Quota
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the site collections information in a SharePoint Online tenant
function Create-SPOSiteCollection
{
    param ($sUserName,$sMessage,$sSiteColTitle,$sSiteColUrl,$sOwner,$iLocaleID,$sTemplateID,$iStorageQuota)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Creating a new Site Collection in SharePoint Online" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $msolcred = get-credential -UserName $sUserName -Message $sMessage
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred
        New-SPOSite -Title $sSiteColTitle -Url $sSiteColUrl -Owner $sOwner -LocaleId $iLocaleID -Template $sTemplateID -StorageQuota $iStorageQuota
        
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Site Collection succesfully created!!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
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
$sSiteColTitle="SPO PowerShell Site Col"
$sSiteColUrl="https://<YourDomain>.sharepoint.com/sites/SPOPowerShellSiteC"
$sOwner="<Office365User>@<YourDomain>.onmicrosoft.com"
$iLocaleID=3082
$sTemplateID="STS#0"
$iStorageQuota=1024
Create-SPOSiteCollection -sUserName $sUserName -sMessage $sMessage -sSiteColTitle $sSiteColTitle -sSiteColUrl $sSiteColUrl -sOwner $sOwner -iLocaleID $iLocaleID -sTemplateID $sTemplateID -iStorageQuota $iStorageQuota



