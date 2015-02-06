############################################################################################################################################
# Script that gets all the available SharePoint Online PowerShell cmdlets
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
############################################################################################################################################
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the SharePoint Online PowerShell cmdlets
function Get-SPOPowerShellCmdlets
{
    param ($sUserName,$sMessage)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the SharePoint Online PowerShell cmdlets" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $msolcred = get-credential -UserName $sUserName -Message $sMessage
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred
        $spoCmdlets=Get-Command | where {$_.ModuleName -eq "Microsoft.Online.SharePoint.PowerShell"}
        Write-Host "There are " $spoCmdlets.Count " Cmdlets in SharePoint Online"
        $spoCmdlets
     
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="jcgonzalez@nuberosnet.onmicrosoft.com"
$sMessage="dsasf"
$sSPOAdminCenterUrl="https://nuberosnet-admin.sharepoint.com/"

Get-SPOPowerShellCmdlets -sUserName $sUserName -sMessage $sMessage



