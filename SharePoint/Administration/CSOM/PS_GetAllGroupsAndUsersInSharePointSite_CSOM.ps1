############################################################################################################################################
#Script that allows to get all the users per SharePoint Group in a SharePoint Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sDomain: AD Domain for the user.
#  -> $sSiteColUrl: Site Collection Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the SharePoint groups and Users per Group in a SharePoint site
function Get-SPAllSharePointUsersInGroups
{
    param ($sSiteColUrl,$sUserName,$sDomain,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all Groups in a SharePoint Site" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "C:\Scripts PS\02 Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "C:\Scripts PS\02 Office 365\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spCredentials = New-Object System.Net.NetworkCredential($sUserName,$sPassword,$sDomain) 
        $spCtx.Credentials = $spCredentials 

        #Root Web Site
        $spRootWebSite = $spCtx.Web
        #Collecction of Sites under the Root Web Site
        $spSites = $spRootWebSite.Webs

        #Loading Operations
        $spGroups=$spCtx.Web.SiteGroups
        $spCtx.Load($spGroups)
        $spCtx.ExecuteQuery()       
        
        #We need to iterate through the $spGroups Object in order to get individual Group information
        foreach($spGroup in $spGroups){
            $spCtx.Load($spGroup)
            $spCtx.ExecuteQuery()
            Write-Host "* " $spGroup.Title

            #Getting the users per group in the SPO Site
            $spSiteUsers=$spGroup.Users
            $spCtx.Load($spSiteUsers)
            $spCtx.ExecuteQuery()
            foreach($spUser in $spSiteUsers){
                Write-Host "    -> User:" $spUser.Title " - User ID:" $spUser.Id " - User E-Mail" $spUser.Email " - User Login" $spUser.LoginName                
            }
        }

        $spCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "http://<Site_Url>" 
$sUserName = "<UserName>" 
$sDomain="<Domain>"
$sPassword ="<UserPassword>" 


Get-SPAllSharePointUsersInGroups -sSiteColUrl $sSiteColUrl -sUserName $sUsername -sDomain $sDomain -sPassword $sPassword