############################################################################################################################################
#Script that allows to get user profile information
# Required Parameters:
#  -> $sCSOMPath: Path for the Client Side Object Model for SPO.
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Administration Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets user profile information
function Get-UserProfileInfo
{
    param ($sCSOMPath,$sSiteUrl,$sUserName,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the User Profile Information for current user" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
                    
        #Adding the Client OM Assemblies
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"  
        $sCSOMUserProfilesPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.UserProfiles.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath
        Add-Type -Path $sCSOMUserProfilesPath

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials        
        $spoUserProfilesLoader=[Microsoft.SharePoint.Client.UserProfiles.ProfileLoader]::GetProfileLoader($spoCtx)
        $spoProfile=$spoUserProfilesLoader.GetUserProfile()
        $spoCtx.Load($spoProfile)
        $spoCtx.ExecuteQuery()
        $spoProfile
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "<https://<SPO_Site_Url> 
$sUserName = "<SPOUser>@<SPODomain>.onmicrosoft.com" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString
$sCSOMPath="<CSOM_Path>"

Get-UserProfileInfo -sCSOMPath $sCSOMPath -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword