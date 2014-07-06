############################################################################################################################################
# Script that allows to remove query suggestions from the SharePoint Search.
# Required Parameters:
#    ->$sQuerySuggestion: Query suggestion to rmeove
#    ->$sLanguage: Language for the Query Suggestions.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that removes a query suggestion from the SharePoint Search
function Remove-QuerySuggestions
{   
    param ($sQuerySuggestion,$sLanguage)  
    try
    {                
        Write-Host "Removing Query Suggestion $sQuerySuggestion" -ForegroundColor Green
        $ssaSearchApp = Get-SPEnterpriseSearchServiceApplication -Identity “Search Service App"
        $spSearchOwner = Get-SPEnterpriseSearchOwner -Level SSA
        Remove-SPEnterpriseSearchLanguageResourcePhrase -SearchApplication $ssaSearchApp  -Language $sLanguage -Type QuerySuggestionAlwaysSuggest -Identity $sQuerySuggestion -Owner $spSearchOwner -Confirm:$false

        #Starting the Timer Job that makes available new query suggestions
        $qsTimerJob = Get-SPTimerJob -type "Microsoft.Office.Server.Search.Administration.PrepareQuerySuggestionsJobDefinition"
        Write-Host "Starting " $qsTimerJob.Name " Timber Job" -ForegroundColor Green
        $qsTimerJob.RunNow()
        Write-Host "Query Suggestion $sQuerySuggestion successfully removed!!" -ForegroundColor Green

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sLanguage="ES-es"
$sQuerySuggestion="Atlético de Madrid"
Remove-QuerySuggestions -sQuerySuggestion $sQuerySuggestion -sLanguage $sLanguage
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell