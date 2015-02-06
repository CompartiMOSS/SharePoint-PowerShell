############################################################################################################################################
#Script that gets all the property Bags in a SharePoint Site Collection using Client Side Object Model 
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"
 
#Definition of the function that allows to read property bags in a SharePoint Site Collection
function ReadSiteCollection-PropertyBags
{
    param ($sSiteColUrl,$sUserName,$sDomain,$sPassword)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spCredentials = New-Object System.Net.NetworkCredential($sUserName,$sPassword,$sDomain)  
        $spCtx.Credentials = $spCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Reading PropertyBags values for $sSiteColUrl !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        
        $spSiteCollection=$spCtx.Site
        $spCtx.Load($spSiteCollection)
        $spRootWeb=$spSiteCollection.RootWeb
        $spCtx.Load($spRootWeb)        
        $spAllSiteProperties=$spRootWeb.AllProperties
        $spCtx.Load($spAllSiteProperties)
        $spCtx.ExecuteQuery()                
        $spPropertyBagKeys=$spAllSiteProperties.FieldValues.Keys
        #$spoPropertyBagKeys
        foreach($spPropertyBagKey in $spPropertyBagKeys){
            Write-Host "PropertyBag Key: " $spPropertyBagKey " - PropertyBag Value: " $spAllSiteProperties[$spPropertyBagKey] -ForegroundColor Green
        }        
        $spCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "http://<SiteCollectionUrl>" 
$sUserName = "<UserName>" 
$sDomain="<AD_Domain>"
$sPassword =""<AD_Domain>"

ReadSiteCollection-PropertyBags -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sDomain $sDomain -sPassword $sPassword



