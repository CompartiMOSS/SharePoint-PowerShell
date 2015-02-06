############################################################################################################################################
#Script that allows to add Users to a SPO Group
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: SharePoint Online Site
#  -> $sGroup: SPO Group where users are going to be added
#  -> $sUser: User to be added
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a SharePoint Group in a SharePoint Online Site
function Add-SPOUsersToGroup
{
    param ($sSiteColUrl,$sUserName,$sPassword,$sGroup,$sUserToAdd)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      
    

        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://nuberosnet.sharepoint.com/sites/SPSaturdayCol/" 
$sUserName = "jcgonzalez@nuberosnet.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "6805&DDT" -asplaintext -force
$sGroup="CustomSPOGroup"
$sUserToAdd="i:0#.f|membership|jcgonzalez@nuberosnet.onmicrosoft.com"

Add-SPOUsersToGroup -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sGroup $sGroup -sUserToAdd $sUserToAdd