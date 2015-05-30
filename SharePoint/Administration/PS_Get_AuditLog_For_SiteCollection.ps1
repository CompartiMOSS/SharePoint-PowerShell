############################################################################################################################################
# This script allows to get the Audit Log Information for a Site Collection
# Required Parameters: 
#    ->$sSiteCollection: Site Collection Url.
#    ->$iUserID: ID of the User we want to get all the required information.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to get information about a user specifying the user ID
function GetSiteUserByID
{
    param ($sSiteCollection,$iUserID)
    $sUserName=""
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollection
        $spwWeb=$spSite.OpenWeb()        
        $spUser=$spwWeb.Users.GetByID($iUserID)
        $sUserName=$spUser.Name

        $spwWeb.Dispose() 	
        $spSite.Dispose()
    }
    catch [System.Exception]
    {  
        $sUserName="User Not Found"
    }
    return, $sUserName
}

#Definition of the function that allows to do the CAML query
function GetAuditLogForASiteCollection
{
    param ($sSiteCollection)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollection
        $spwWeb=$spSite.OpenWeb()
        $spAuditQuery=New-Object Microsoft.SharePoint.SPAuditQuery($spSite)
        $spAuditEntries=$spSite.Audit.GetEntries($spAuditQuery)
        Write-Host "# of records in the Audit Log: " $spAuditEntries.Count -ForegroundColor Green
        foreach($spAuditEntry in $spAuditEntries){
            $sUser=GetSiteUserByID -sSiteCollection $sSiteCollection -iUserID $spAuditEntry.UserId
            Write-Host "Doc Location: " $spAuditEntry.DocLocation " - Event: " $spAuditEntry.Event " - User: " $spAuditEntry.UserId ";" $sUser -Foregroundcolor White
        }
        $spwWeb.Dispose() 	
        $spSite.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sSiteCollection="http://<Site_Collection_Url>"
GetAuditLogForASiteCollection -sSiteCollection $sSiteCollection
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell