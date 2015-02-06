############################################################################################################################################
# Script that allows to get all the query suggestions already defined in a SharePoint farm.
# Required Parameters:
#    -> N/A
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets current query suggestions in the SharePoint farm
function Get-QuerySuggestions
{
    try
    {        
        Write-Host "Getting all the query suggestions..." -ForegroundColor Green
        $ssaSearchApp = Get-SPEnterpriseSearchServiceApplication -Identity “Search Service App"
        $spSearchOwner = Get-SPEnterpriseSearchOwner -Level SSA
        Get-SPEnterpriseSearchQuerySuggestionCandidates -SearchApplication $ssaSearchApp -Owner $spSearchOwner
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
Get-QuerySuggestions
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell