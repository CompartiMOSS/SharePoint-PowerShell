############################################################################################################################################
# Script that allows to get for every user in an Office 365 Tenant information about the subscription for the user and the services being used
# All the information is exported to a CSV file
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sExportFile: CSV File.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to get the subscription and service information for all the users in an Office 365 tenant
function Get-Office365UsersAndLicenses
{  
    param ($sExportFile)  
    try
    {       
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting for each Office 365 user the suscription information and the services in use." -foregroundcolor Green
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        $O365Users=Get-MsolUser | Select UserPrincipalName,DisplayName, @{Name="Assigned License"; Expression={$_.Licenses.AccountSkuId}}, @{Name="Yammer";Expression={$_.Licenses[0].ServiceStatus[0].ProvisioningStatus}}, @{Name="Office 365";Expression={$_.Licenses[0].ServiceStatus[1].ProvisioningStatus}}, @{Name="Office Professional";Expression={$_.Licenses[0].ServiceStatus[2].ProvisioningStatus}}, @{Name="Lync";Expression={$_.Licenses[0].ServiceStatus[3].ProvisioningStatus}}, @{Name="Office Web Apps";Expression={$_.Licenses[0].ServiceStatus[4].ProvisioningStatus}}, @{Name="SharePoint";Expression={$_.Licenses[0].ServiceStatus[5].ProvisioningStatus}}, @{Name="Exchange";Expression={$_.Licenses[0].ServiceStatus[6].ProvisioningStatus}}
        $O365Users
        $O365Users | export-csv -path $sExportFile -notype
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    } 
}

#Office 365 Connection Parameters
$sUserName="<Office365User>@<Office365Domain>.onmicrosoft.com"
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365
$msolcred = get-credential -UserName $sUserName -Message $sMessage
connect-msolservice -credential $msolcred

#Calling the function
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sPath = Get-Location
$sExportFile=$ScriptDir + "\" + "$path\$sSiteName" + "Office365_Users_And_Licenses.csv"
Get-Office365UsersAndLicenses -sExportFile $sExportFile

###################################################################################################################################
#References:
# -> http://technet.microsoft.com/es-es/library/dn771771.aspx
# -> http://social.technet.microsoft.com/wiki/contents/articles/11349.office-365-license-users-for-office-365-workloads.aspx
###################################################################################################################################