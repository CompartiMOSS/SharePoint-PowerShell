############################################################################################################################################
# Script that allows to find all the ocurrences for a Correlation ID in the SharePoint Loigs
# Required Parameters: 
#    -> $sCorrelationID: Correlation ID to look for
#    -> $sLogFile: Name of the log file where the information obtained is stored
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that finds a specific correlation ID in SharePoint Log Files
function Find-CorrelationID
{
    param ($sCorrelationID,$sLogFile) 
    try
    {
        Write-Host "Finding the correlation ID $sCorrelationID in SharePoint Logs" -foregroundcolor Green
        Get-SPLogEvent | ?{$_.Correlation -eq $sCorrelationID} | select Area, Category, Level, EventID, Message | Format-List > $sLogFile
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sCorrelationID="9fd3251e-b81f-45f8-b2b7-044b64418f55"
$sScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sLogFile=$sScriptDir + "\CorrelationIDLog.log"
Find-CorrelationID -sCorrelationID $sCorrelationID -sLogFile $sLogFile
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell

