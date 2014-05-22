############################################################################################################################################
# Script to change the default upload file size through the Client Side Object Model (CSOM)
# Required Parameters: 
#    ->$iFileSize: New upload file size throught CSOM.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to change the default upload file size for CSOM
function ChangeFileSizeCSOM([int]$iFileSize)
{   
    try
    {
    	$spWS = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
        Write-Host "Valor por defecto de carga de archivos con CSOM " $spWS.ClientRequestServiceSettings.MaxReceivedMessageSize -ForegroundColor Yellow
        Write-Host "Cambiando el tamaño de carga de archivos con CSOM a $iFileSize" -ForegroundColor Green
	$spWS.ClientRequestServiceSettings.MaxReceivedMessageSize = $iFileSize
        $spWS.ClientRequestServiceSettings.MaxParseMessageSize=$iFileSize
	$spWS.Update()
    }
    catch [System.Exception]
    {
        Write-Host $_.Exception.ToString() -ForegroundColor Red
    }
}

Start-SPAssignment -Global
ChangeFileSizeCSOM -iFileSize 5242880
Stop-SPAssignment -Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell
