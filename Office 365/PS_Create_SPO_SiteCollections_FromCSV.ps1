############################################################################################################################################
# Script that allows to create a new site collection in SharePoint Online
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> sInputFile: CSV File with the Site Collections information.
#  -> $sRootSiteCollection: Root Site Collection Url in the SharePoint Online Tenant
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that creates a Site Colleciton in SharePoint Online
function Create-SPOSiteCollection
{
    param ($sSiteColTitle,$sSiteColUrl,$sOwner,$iLocaleID,$sTemplateID,$iStorageQuota,$iResourcesQuota,$iTimeZone)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Creating a new Site Collection in SharePoint Online" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        New-SPOSite -Title $sSiteColTitle -Url $sSiteColUrl -Owner $sOwner -LocaleId $iLocaleID -Template $sTemplateID -StorageQuota $iStorageQuota -ResourceQuota $iResourcesQuota -TimeZoneId $iTimeZone
        
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Site Collection $sSiteColTitle succesfully created!!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Function that allows to create several site collections in SharePoint Online reading the information from a CSV file
function Create-SPOSiteCollectionsFromCSV
{
    param ($sInputFile,$sRootSiteCollection)
    try
    {   
        # Reading the Users CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblSiteCollections = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -foregroundcolor Red
            exit 
        }                
        
        # Creating the Site Collections 
        foreach ($SC in $tblSiteCollections) 
        {   
            $sSiteColUrl=$sRootSiteCollection + $SC.SiteCRelativeUrl
            Create-SPOSiteCollection -sSiteColTitle $SC.SiteCTitle -sSiteColUrl $sSiteColUrl -sOwner $SC.SiteCollectionOwner -iLocaleID $SC.SCCulture -sTemplateID $SC.SiteCTemplate -iStorageQuota $SC.SCStorageQuota -iResourcesQuota $SC.SCResourcesQuota -iTimeZone $SC.SCTimeZone
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    } 
}


#Connection to Office 365
$sUserName="<Office365User>@<Office365Domain>.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<Office365Domain>-admin.sharepoint.com/"
$msolcred = get-credential -UserName $sUserName -Message $sMessage
Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred

#Parameters to create the site collections from a CSV file
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\PS_SiteCollectionsToCreate.csv"
$sRootSiteCollection="https://<Office365Domain>.sharepoint.com/"
        
Create-SPOSiteCollectionsFromCSV -sInputFile $sInputFile -sRootSiteCollection $sRootSiteCollection

