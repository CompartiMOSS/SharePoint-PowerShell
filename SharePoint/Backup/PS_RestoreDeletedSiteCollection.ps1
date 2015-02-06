############################################################################################################################################
# Script that allows to restore a deleted site collection
# Required Parameters: 
#    ->$sSiteCollectionToRestore: Site Collection to be restored.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that restores de deleted Site Collection
function Restore-DeletedSC
{
    param ($sSiteCollectionToRestore)
    try
    {
   	$spColeccionBorrada=Get-SPDeletedSite $sSiteCollectionToRestore
	Restore-SPDeletedSite -Identity $spColeccionBorrada.SiteId
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
Restore-DeletedSC -sSiteCollectionToRestore "/"
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell