############################################################################################################################################
#Script that allows to create a SharePoint Group in a SharePoint Online Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: SharePoint Online Site
#  -> $sGroupToCreate: SPO Group to create
#  -> $sGroupToCreateDescription: SPO Group description
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a SharePoint Group in a SharePoint Online Site
function Create-SPOGroup
{
    param ($sSiteColUrl,$sUsername,$sPassword,$sGroupToCreate,$sGroupToCreateDescription)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Creating SharePoint Group $sGroupToCreate in $sSiteColUrl" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 

        #Root Web Site
        $spoRootWebSite = $spoCtx.Web
        #Object for creating a new SPO Group
        $spoGroupCreationInfo=New-Object Microsoft.SharePoint.Client.GroupCreationInformation
        $spoGroupCreationInfo.Title=$sGroupToCreate
        $spoGroupCreationInfo.Description=$sGroupToCreateDescription
        $spoGroup=$spoRootWebSite.SiteGroups.Add($spoGroupCreationInfo)
        $spoCtx.ExecuteQuery()
        
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "SharePoint Group $sGroupToCreate in $sSiteColUrl created succesfully!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<SPO_Site>/" 
$sUsername = "<SPO_User>" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<Password>" -asplaintext -force
$sGroupToCreate="CustomSPOGroup"
$sGroupToCreateDescription="Custom SPO Group"

Create-SPOGroup -sSiteColUrl $sSiteColUrl -sUsername $sUsername -sPassword $sPassword -sGroupToCreate $sGroupToCreate -sGroupToCreateDescription $sGroupToCreateDescription