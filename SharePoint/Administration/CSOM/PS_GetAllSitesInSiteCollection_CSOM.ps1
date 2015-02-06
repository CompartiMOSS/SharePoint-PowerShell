############################################################################################################################################
# Script that allows to get all the sites defined under a SharePoint  Site Collection using CSOM
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sDomain: AD Domain for the user.
#  -> $sSiteColUrl: Site Collection Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the sites in a SharePoint Site Collection
function Get-SPSitesInSC
{
    param ($sSiteColUrl,$sUserName,$sDomain,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the sites in a SharePoint Online Site Collection" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SharePoint Client Object Model Context
        $spCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spCredentials = New-Object System.Net.NetworkCredential($sUserName,$sPassword,$sDomain)  
        $spCtx.Credentials = $spCredentials 

        #Root Web Site
        $spRootWebSite = $spCtx.Web
        #Collecction of Sites under the Root Web Site
        $spSites = $spRootWebSite.Webs

        #Loading operations        
        $spCtx.Load($spRootWebSite)
        $spCtx.Load($spSites)
        $spCtx.ExecuteQuery()

        #We need to iterate through the $spoSites Object in order to get individual sites information
        foreach($spSite in $spSites){
            $spCtx.Load($spSite)
            $spCtx.ExecuteQuery()
            Write-Host $spSite.Title " - " $spSite.Url -ForegroundColor Green
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
$sPassword ="<Password>" 


Get-SPSitesInSC -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sDomain $sDomain -sPassword $sPassword