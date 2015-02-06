############################################################################################################################################
# Script that allows to get all the SharePoint groups in a SharePoint Online Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: SharePoint Online Site
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the SharePoint groups in a SharePoint Online site
function Get-SPOSharePointGroupsInSite
{
    param ($sSiteColUrl,$sUsername,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all Groups in a SharePoint Online Site" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 

        #Root Web Site
        $spoRootWebSite = $spoCtx.Web
        #Collecction of Sites under the Root Web Site
        $spoSites = $spoRootWebSite.Webs

        #Loading Operations
        $spoGroups=$spoCtx.Web.SiteGroups
        $spoCtx.Load($spoGroups)
        $spoCtx.ExecuteQuery()
        
        #We need to iterate through the $spoGroups Object in order to get individual Group information
        foreach($spoGroup in $spoGroups){
            $spoCtx.Load($spoGroup)
            $spoCtx.ExecuteQuery()
            Write-Host $spoGroup.Title
        }

        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://nuberosnet.sharepoint.com/sites/TrainingSP/" 
$sUsername = "jcgonzalez@nuberosnet.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "6805&DDT" -asplaintext -force

Get-SPOSharePointGroupsInSite -sSiteColUrl $sSiteColUrl -sUsername $sUsername -sPassword $sPassword