############################################################################################################################################
#Script that adds a Bing Maps Key to a SharePoint Online Site Collection
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site Url.
#  -> $sBingMapsKey: Bing Maps Key to be added.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add a Bing Maps Key to a SharePoint Onlione Site Collection
function Add-BingMapsKey
{
    param ($sSiteUrl,$sUserName,$sPassword,$sBingMapsKey)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding Bing Maps Key to $sSiteUrl !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        
        $spoSiteCollection=$spoCtx.Site
        $spoCtx.Load($spoSiteCollection)
        $spoRootWeb=$spoSiteCollection.RootWeb
        $spoCtx.Load($spoRootWeb)        
        $spoAllSiteProperties=$spoRootWeb.AllProperties
        $spoCtx.Load($spoAllSiteProperties)
        $spoRootWeb.AllProperties["BING_MAPS_KEY"]=$sBingMapsKey
        $spoRootWeb.Update()        
        $spoCtx.ExecuteQuery()
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<SPO_Site_Url>" 
$sUserName = "<SPOUser>@<SPODomain>.onmicrosoft.com" 
$sBingMapsKey= "<BingMaps_Key>"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<SPO_Password>" -asplaintext -force

Add-BingMapsKey -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sBingMapsKey $sBingMapsKey

