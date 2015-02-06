############################################################################################################################################
# Script that allows to get all the sites defined under a SharePoint Online Site Collection using CSOM
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: Site Collection Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the site collections information in a SharePoint Online tenant
function Get-SPOSitesInSC
{
    param ($sSiteColUrl,$sUsername,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the sites in a SharePoint Online Site Collection" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "C:\CSOM Path\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "C:\CSOM Path\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 

        #Root Web Site
        $spoRootWebSite = $spoCtx.Web
        #Collecction of Sites under the Root Web Site
        $spoSites = $spoRootWebSite.Webs

        #Loading operations        
        $spoCtx.Load($spoRootWebSite)
        $spoCtx.Load($spoSites)
        $spoCtx.ExecuteQuery()

        #We need to iterate through the $spoSites Object in order to get individual sites information
        foreach($spoSite in $spoSites){
            $spoCtx.Load($spoSite)
            $spoCtx.ExecuteQuery()
            Write-Host $spoSite.Title " - " $spoSite.Url -ForegroundColor Blue
        }
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<YourSharePointSiteCollection>" 
$sUsername = "<YourSPOUser>" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<YourSPOUserPassword>" -asplaintext -force

Get-SPOSitesInSC -sSiteColUrl $sSiteColUrl -sUsername $sUsername -sPassword $sPassword



