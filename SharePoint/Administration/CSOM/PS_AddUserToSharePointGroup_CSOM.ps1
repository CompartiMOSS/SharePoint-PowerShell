############################################################################################################################################
#Script that allows to add Users to a SP Group
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sDomain: AD Domain for the user.
#  -> $sSiteColUrl: Site Collection Url.
#  -> $sGroup: SPO Group where users are going to be added
#  -> $sUserToAdd: User to be added
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a SharePoint Group in a SharePoint Site
function Add-SPUsersToGroup
{
    param ($sSiteColUrl,$sUserName,$sDomain,$sPassword,$sGroup,$sUserToAdd)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding User $sUser to group $sGroup in $sSiteColUrl" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spCredentials = New-Object System.Net.NetworkCredential($sUserName,$sPassword,$sDomain)  
        $spCtx.Credentials = $spCredentials 
        
        #Getting the SharePoint Groups for the site                        
        $spGroups=$spCtx.Web.SiteGroups
        $spCtx.Load($spGroups)        
        #Getting the specific SharePoint Group where we want to add the user
        $spGroup=$spGroups.GetByName($sGroup);
        $spCtx.Load($spGroup)       
        #Ensuring the user we want to add exists
        $spUser = $spCtx.Web.EnsureUser($sUserToAdd)
        $spCtx.Load($spUser)
        $spUserToAdd=$spGroup.Users.AddUser($spUser)
        $spCtx.Load($spUserToAdd)
        $spCtx.ExecuteQuery()     
                
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "SharePoint User $sUser added succesfully!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "http://<SiteUrl>" 
$sUserName = "<UserName>" 
$sDomain="<Domain>"
$sPassword ="<UserPassword>" 
$sGroup="<SharePoint_Group>"
$sUserToAdd="i:0#.w|<Domain\UserName>"

Add-SPUsersToGroup -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sGroup $sGroup -sUserToAdd $sUserToAdd