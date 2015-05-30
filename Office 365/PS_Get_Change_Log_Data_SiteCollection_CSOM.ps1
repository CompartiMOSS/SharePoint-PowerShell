############################################################################################################################################
# Script that allows to get changes available in the Changes Log for a SharePoint Online Site Collection
# Required Parameters:
#  -> $sCSOMPath: Path for the CSOM assemblies.
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: Site Collection Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets changes available in the Changes Log for a SharePoint Online Site Collection
function Get-SPOChangesLogForSC
{
    param ($sCSOMPath,$sSiteColUrl,$sUserName,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all changes in a SharePoint Online Site Collection" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
                #Adding the Client OM Assemblies
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"          
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath       

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 

        #Root Web Site
        $spoRootWebSite = $spoCtx.Web
        $spoCtx.Load($spoRootWebSite)
        $spoCtx.ExecuteQuery()
        Write-Host "Accessing the Change Log for " $spoRootWebSite.Title " - " $spoRootWebSite.Url
        
        #Getting changes in the Change Log
        $spocChangeQuery = New-Object Microsoft.SharePoint.Client.ChangeQuery($true,$true)
        $spocChangesCollection=$spoCtx.Site.GetChanges($spocChangeQuery)
        $spoCtx.Load($spocChangesCollection)
        $spoCtx.ExecuteQuery()
                
        #We need to iterate through the $spcChangesCollection Object in order to get the Changes from the Change Log
        Write-Host "# of Changes found in the first batch " $spocChangesCollection.Count
        
        foreach($spocChange in $spocChangesCollection){
            Write-Host "Change Type: " $spocChange.ChangeType " - Object Type: " $spocChange.TypedObject " - Change Date: " $spocChange.Time  -Foregroundcolor White
        }
        
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<O365Domain>.sharepoint.com/sites/<SiteCollection>" 
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString
$sCSOMPath="<CSOM_Path>"

Get-SPOChangesLogForSC -sCSOMPath $sCSOMPath -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword



