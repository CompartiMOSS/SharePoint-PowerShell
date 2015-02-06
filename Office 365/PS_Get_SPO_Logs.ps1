############################################################################################################################################
#Script that allows to get the logs for SharePoint Online
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Administration Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#http://www.vrdmn.com/2014/03/view-tenant-uls-logs-in-sharepoint.html
#http://stackoverflow.com/questions/10487011/creating-a-datetime-object-with-a-specific-utc-datetime-in-powershell

#Definition of the function that gets the logs for SharePoint Online
function Get-SPOLogs
{
    param ($sSiteUrl,$sUsername,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the logs for SharePoint Online" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"
        Add-Type -Path "H:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.Online.SharePoint.Client.Tenant.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials
        $uTime=Get-Date
        $utcTime=$uTime.ToUniversalTime()
        $spoTenant= New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($spoCtx)
        $spoTenantLog=New-Object Microsoft.Online.SharePoint.TenantAdministration.TenantLog($spoCtx)
        $spoLogEntries=$spoTenantLog.GetEntries($utcTime.AddDays(-500),$utcTime,50)
        #$spoLogEntries=$spoTenantLog.GetEntries()
        $spoCtx.Load($spoLogEntries)
        $spoCtx.ExecuteQuery()
        
        #We need to iterate through the $spoGroups Object in order to get individual Group information
        foreach($spoLogEntry in $spoLogEntries){
            Write-Host $spoLogEntry.TimestampUtc " - " $spoLogEntry.Message  " - " $spoLogEntry.CorrelationId " - " $spoLogEntry.Source " - " $spoLogEntry.User " - " $spoLogEntry.CategoryId   
        }
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://nuberosnet-admin.sharepoint.com/" 
$sUsername = "jcgonzalez@nuberosnet.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "6805&DDT" -asplaintext -force

Get-SPOLogs -sSiteUrl $sSiteUrl -sUsername $sUsername -sPassword $sPassword