############################################################################################################################################
# Script that allows to provision the SharePoint 2013 Subscription Settings Service Application
# Required Parameters: 
#    ->$sAccount: SharePoint Admin account to provision the Subscription Settings Service Application
#    ->$sSPSubsSettingServiceAppName: Subscription Settings Service Application Name
#    ->$spSPSubsSettingSA_DB: Subscription Settings Service Application Database Name
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to provision the SharePoint 2013 Subscription Settings Service Application
function Provision-SPSubscriptionSettingsServiceApplication
{
    param ($sAccount,$sSPSubsSettingServiceAppPoolName,$sSPSubsSettingServiceAppName,$spSPSubsSettingSA_DB)
    try
    {
        Write-Host "Provisining the SP Subscription Settings Service Application!!" -ForegroundColor Green
        $spAccount = Get-SPManagedAccount $sAccount
        #$appPoolSubSvc = New-SPServiceApplicationPool -Name SPSubscriptionSettingsServiceAppPool -Account $spAccount
        $appPoolSubSvc = Get-SPServiceApplicationPool -Identity $sSPSubsSettingServiceAppPoolName
        $appSubSvc = New-SPSubscriptionSettingsServiceApplication –ApplicationPool $appPoolSubSvc –Name $sSPSubsSettingServiceAppName –DatabaseName $spSPSubsSettingSA_DB
        $proxySubSvc = New-SPSubscriptionSettingsServiceApplicationProxy –ServiceApplication $appSubSvc
        Write-Host "SP Subscription Settings Service Application succesfully provisioned!!" -ForegroundColor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sAccount="itechcs\spadmin"
$sSPSubsSettingServiceAppPoolName="SPSubscriptionSettingsServiceAppPool"
$sSPSubsSettingServiceAppName="SP_SubscriptionSettingsServiceApplication"
$spSPSubsSettingSA_DB="SPSubscriptionSettingsService_DB"

Provision-SPSubscriptionSettingsServiceApplication -sAccount $sAccount -sSPSubsSettingServiceAppPoolName $sSPSubsSettingServiceAppPoolName -sSPSubsSettingServiceAppName $sSPSubsSettingServiceAppName -spSPSubsSettingSA_DB $spSPSubsSettingSA_DB

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell