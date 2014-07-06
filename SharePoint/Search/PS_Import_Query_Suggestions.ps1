############################################################################################################################################
# Script that allows to import query suggestions to the SharePoint Search.
# Required Parameters:
#    ->$sInputfile: Query suggestions file.
#    ->$sLanguage: Language for the Query Suggestions.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that imports new query suggestions to SharePoint
function Import-QuerySuggestions
{   
    param ($sInpuntFile,$sLanguage)  
    try
    {        
        Write-Host "Importing Query Suggestions.." -ForegroundColor Green
        #Checking if the query suggestions file exists
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblData = Import-CSV $sInputFile            
        } else { 
            Write-Host "File $sInputFile not found. Stopping the Import Process!" -foregroundcolor Red
            exit 
        }        
        
        $ssaSearchApp = Get-SPEnterpriseSearchServiceApplication -Identity “Search Service App"
        $spSearchOwner = Get-SPEnterpriseSearchOwner -Level SSA
        
        #Processing the file data
        foreach ($row in $tblData){      
            $sQuerySuggestion=$row.QuerySuggestion.ToString()           
            Write-Host "Adding $sQuerySuggestion as a Query Suggestion"
            New-SPEnterpriseSearchLanguageResourcePhrase -SearchApplication  $ssaSearchApp -Language $sLanguage -Type QuerySuggestionAlwaysSuggest -Name $sQuerySuggestion -Owner $spSearchOwner 
        } 

        #Starting the Timer Job that makes available new query suggestions
        $qsTimerJob = Get-SPTimerJob -type "Microsoft.Office.Server.Search.Administration.PrepareQuerySuggestionsJobDefinition"
        Write-Host "Starting " $qsTimerJob.Name " Timber Job" -ForegroundColor Green
        $qsTimerJob.RunNow()
        Write-Host "Query Suggestions successfully imported!!" -ForegroundColor Green

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Archivo con los Usuarios
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\QuerySuggestions_Madrid.txt"
$sLanguage="ES-es"
Import-QuerySuggestions -sInpuntFile $sInputFile -sLanguage $sLanguage
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell