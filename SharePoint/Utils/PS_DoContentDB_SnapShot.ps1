############################################################################################################################################
# Script that allows to do an snapshot of SharePoint Content Database
# Required Parameters: 
#    ->$sSiteUrl: Site Url to get the Content DB
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that performs the Content Database Snapshot
function DoContentDBSnapShot
{
    param ($sSiteUrl)
    try
    {
        Write-Host "Doing the Snapshot for $sWebApplication !!" -ForegroundColor Blue
        $sContentDB=Get-SPContentDatabase -Site $sSiteUrl
        $sContentDB.Snapshots.CreateSnapshot()
        Write-Host "Snapshot for $sWebApplication successfully completed!!" -ForegroundColor Blue
   	
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
DoContentDBSnapshot -sSiteUrl "http://<Site_Url>"

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell
