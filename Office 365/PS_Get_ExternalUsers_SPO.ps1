############################################################################################################################################
# Script that allows to get all the external users in a SharePoint Online Tenant.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the external users in a SharePoint Online Tenant.
function Get-SPOExternalUsers
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the external users in a SharePoint Online Tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $msolcred = Get-Credential -UserName $sUserName -Message $sMessage
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred 
        Get-SPOExternalUser -Position 0 -PageSize 30 | Select DisplayName,EMail | Format-Table

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="jcgonzalez@nuberosnet.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://nuberosnet-admin.sharepoint.com/"

Get-SPOExternalUsers -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl
