############################################################################################################################################
# Script that allows to Warm Up all the sites in a SharePoint Farm.
# Required Parameters: None
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

Start-SPAssignment –Global

#Definición de la función que obtiene el tamaño de las BD's de contenidos
function Do-WarmUp
{  
    try
    {
        Write-Host "SharePoint Initialization Processs Completed succesfully!" -ForegroundColor Blue        
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration        
        foreach ($spWebApp in $spWebApps)
        {           
            Write-Host "Initializing $($spWebApp.URL)"
            Invoke-WebRequest $spWebApp.URL -UseDefaultCredentials -UseBasicParsing                               
        }         
        Write-Host "SharePoint Initialization Processs Completed succesfully!" -ForegroundColor Blue
    }
    catch
    {
        Write-Host -Object ("Status: " + $Error[0].Exception.Message) -ForegroundColor Red
    }
}

Start-SPAssignment –Global
Do-WarmUp
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell 