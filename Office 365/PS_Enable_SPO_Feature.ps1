############################################################################################################################################
#Script that enables a feature in a SPO Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: SharePoint Online Site Collection
#  -> $sFeatureGuid: GUID of the feature to be enabled
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to enable a SPO Feature
function Enable-SPOFeature
{
    param ($sSiteColUrl,$sUserName,$sPassword,$sFeatureGuid)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Enabling the Feature with GUID $sFeatureGuid !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green

        $guiFeatureGuid = [System.Guid] $sFeatureGuid
        $spoSite=$spoCtx.Site
        $spoSite.Features.Add($sFeatureGuid, $true, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None)
        $spoCtx.ExecuteQuery()
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<SPODomain>.sharepoint.com/<SPOSite>" 
$sUserName = "<SPOUser>@<SPODomain>.onmicrosoft.com" 
$sFeatureGuid= "f6924d36-2fa8-4f0b-b16d-06b7250180fa"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<SPOPassword>" -asplaintext -force

Enable-SPOFeature -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sFeatureGuid $sFeatureGuid

