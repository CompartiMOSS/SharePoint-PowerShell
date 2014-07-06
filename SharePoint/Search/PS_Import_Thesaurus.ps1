############################################################################################################################################
# Script that allows to import a Theasurus file definition to be used by the search engine.
# Required Parameters:
#    ->$sTheasurusFilePath: Theasurus File Path
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that imports the theasurus file
function Import-TheasurusFIle
{
    param ($sTheasurusFilePath)
    try
    {
        $searchApp = Get-SPEnterpriseSearchServiceApplication 
        Import-SPEnterpriseSearchThesaurus -SearchApplication $searchApp -Filename $sTheasurusFilePath  	
        Write-Host "Theasurus file $sTheasurusFilePath imported successfully!" -ForegroundColor Blue
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}


Start-SPAssignment –Global
$sTheasurusFilePath="\\C4968397007\Demos\Formacion SP Avanzada\Busquedas\Sample_Thesaurus.csv"

Import-TheasurusFIle -sTheasurusFilePath $sTheasurusFilePath
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell