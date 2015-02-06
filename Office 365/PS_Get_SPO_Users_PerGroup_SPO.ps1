############################################################################################################################################
# Script that allows to get all the users per SharePoint Group in a SharePoint Online Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: SharePoint Online Site
############################################################################################################################################
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the users per SharePoint group in a SharePoint Online site
function Get-SPOSharePointUsersPerGroup
{
    param ($sSPOAdminCenterUrl,$sSiteUrl,$sUserName,$sPassword)
    try
    {    
        Write-Host "--------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all Users per Group in a SharePoint Online Site" -foregroundcolor Green
        Write-Host "--------------------------------------------------------------------------------"  -foregroundcolor Green     
        $msolcred = Get-Credential -UserName $sUserName -Message $sMessage
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred
        $spoGroups=Get-SPOSiteGroup -Site $sSiteUrl

        foreach($spoGroup in $spoGroups){         
           Write-Host "Users in " $spoGroup.Title ":"
           $spoUsers=Get-SPOUser -Site $sSiteUrl -Group $spoGroup.Title
           Write-Host " -> " $spoUsers.LoginName
           Write-Host "---------------------------------------------------" -ForegroundColor Green
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<SharePointOnline_SiteUrl" 
$sUserName = "<SharePointOnlineUser>" 
$sMessage="<Custom_Prompt_Message>"
$sSPOAdminCenterUrl="https://<SPODomain>-admin.sharepoint.com/"

Get-SPOSharePointUsersPerGroup -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSiteUrl $sSiteUrl -sUserName $sUsername -sPassword $sPassword

