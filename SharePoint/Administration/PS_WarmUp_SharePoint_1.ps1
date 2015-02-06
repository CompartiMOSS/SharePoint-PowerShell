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

        "Creating an Internet Explorer object for navigation."
        $ie = New-Object -ComObject InternetExplorer.Application
 
        Write-Host "Enumerate the SharePoint sites." -ForegroundColor Blue
        $spWebs = Get-SPWebApplication -IncludeCentralAdministration | Get-SPSite | Get-SPWeb -Limit All
 
        "Navigating to all $($spWebs.Count) sites."
        foreach ($spWeb in $spWebs)
        {
            "Initializing $($spWeb.URL)"
            $ie.Navigate($spWeb.URL)
            while ($ie.Busy)
            {
                Start-Sleep -Seconds 1
            }
            Write-Host "SharePoint Site $($ie.Document.title) has been initialized" -ForegroundColor Blue
         }
         $ie.Quit() 
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
