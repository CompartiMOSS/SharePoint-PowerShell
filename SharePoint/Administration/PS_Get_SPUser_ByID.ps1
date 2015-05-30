############################################################################################################################################
# This script allows to do get a SharePoint User in a Site by User ID
# Required Parameters: 
#    ->$sSiteCollection: Site Collection Url.
#    ->$iUserID: ID of the User we want to get all the required information
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
        write-host -f red $_.Exception.ToString()
        $sUserName="User Not Found"
    }
    return, $sUserName
}

Start-SPAssignment –Global
#Calling the function
$sSiteCollection="http://<Site_Collection_Url>"
$iUserID=1
GetSiteUserByID -sSiteCollection $sSiteCollection -iUserID $iUserID
$iUserID=234567
GetSiteUserByID -sSiteCollection $sSiteCollection -iUserID $iUserID
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell