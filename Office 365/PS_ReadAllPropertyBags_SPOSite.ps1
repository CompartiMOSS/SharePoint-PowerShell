############################################################################################################################################
#Script that gets all the property Bags 
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"
 
#Definition of the function that allows to read property bags in SharePoint Online
function ReadSPO-PropertyBags
{
    param ($sSiteUrl,$sUserName,$sPassword)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Reading PropertyBags values for $sSiteUrl !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        
        $spoSiteCollection=$spoCtx.Site
        $spoCtx.Load($spoSiteCollection)
        $spoRootWeb=$spoSiteCollection.RootWeb
        $spoCtx.Load($spoRootWeb)        
        $spoAllSiteProperties=$spoRootWeb.AllProperties
        $spoCtx.Load($spoAllSiteProperties)
        $spoCtx.ExecuteQuery()                
        $spoPropertyBagKeys=$spoAllSiteProperties.FieldValues.Keys
        #$spoPropertyBagKeys
        foreach($spoPropertyBagKey in $spoPropertyBagKeys){
            Write-Host "PropertyBag Key: " $spoPropertyBagKey " - PropertyBag Value: " $spoAllSiteProperties[$spoPropertyBagKey] -ForegroundColor Green
        }        
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://fiveshareit.sharepoint.com/sites/mvpcluster/" 
$sUserName = "juancarlos.gonzalez@fiveshareit.es" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "647391&jc" -asplaintext -force

ReadSPO-PropertyBags -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword

