############################################################################################################################################
#Script that allows to asynchronously provision OneDrive For Business for a set of users
# Required Parameters:
#  -> $sCSOMPath: Path for the Client Side Object Model for SPO.
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Administration Url.
#  -> $ODFBUser: Office 365 user .
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to provision ODFB for a set of users
function Create-ODFBSite
{
    param ($sCSOMPath,$sSiteUrl,$sUserName,$sPassword,$sODFBUsers)
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
        $spoUserProfilesLoader.CreatePersonalSiteEnqueueBulk($sODFBUsers)
        $spoUserProfilesLoader.Context.ExecuteQuery()
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<SPO_Site_Url>/" 
$sUserName = "<SPOUser>@<SPO_Domain>.onmicrosoft.com" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString
$sCSOMPath="<CSOM_Path>"
$sODFBUsers="<SPOUser1>@<SPO_Domain>.onmicrosoft.com","<SPOUser2>@<SPO_Domain>.onmicrosoft.com"

Create-ODFBSite -sCSOMPath $sCSOMPath -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sODFBUsers $sODFBUsers