############################################################################################################################################
#Script that allows to add Users to a SPO Group
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: SharePoint Online Site
#  -> $sGroup: SPO Group where users are going to be added
#  -> $sUserToAdd: User to be added
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a SharePoint Group in a SharePoint Online Site
function Add-SPOUsersToGroup
{
    param ($sSiteColUrl,$sUsername,$sPassword,$sGroup,$sUserToAdd)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding User $sUser to group $sGroup $sSiteColUrl" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 
        
        #Getting the SharePoint Groups for the site                        
        $spoGroups=$spoCtx.Web.SiteGroups
        $spoCtx.Load($spoGroups)        
        #Getting the specific SharePoint Group where we want to add the user
        $spoGroup=$spoGroups.GetByName($sGroup);
        $spoCtx.Load($spoGroup)       
        #Ensuring the user we want to add exists
        $spoUser = $spoCtx.Web.EnsureUser($sUserToAdd)
        $spoCtx.Load($spoUser)
        $spoUserToAdd=$spoGroup.Users.AddUser($spoUser)
        $spoCtx.Load($spoUserToAdd)
        $spoCtx.ExecuteQuery()     
                
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "SharePoint User $sUser added succesfully!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<Office365_Site>" 
$sUsername = "<Office365_UserAccount>" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<Office365_Password>" -asplaintext -force
$sGroup="<SPO_Group>"
$sUserToAdd="i:0#.f|membership|<Office365_UserAccount>"

Add-SPOUsersToGroup -sSiteColUrl $sSiteColUrl -sUsername $sUsername -sPassword $sPassword -sGroup $sGroup -sUserToAdd $sUserToAdd