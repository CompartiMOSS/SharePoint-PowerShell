############################################################################################################################################
# This script allows to play with ReadOnly and ManteinanceMode properties at the Site Collection Level
# Required Parameters: 
#    ->$sSiteCollection: Site Collection where we are going to do the backup / restore.
#    ->$sOperationType: Operation Type (Read / Modify properties).
#    ->$sReadOnlyMode: Read Only mode for the ReadOnly property.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that restores de deleted Site Collection
function ReadModify-SPSiteProperties
{
    param ($sSiteCollection,$sOperationType,$sReadOnlyMode)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollection
        
        #Operation Type
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Reading $sSiteCollection values for ReadOnly & ManteinanceMode properties!!" -ForegroundColor Green
            Write-Host "Value for ReadOnly property: " $spSite.ReadOnly -ForegroundColor Green
            Write-Host "Value for ManteinanceMode property: " $spSite.MaintenanceMode -ForegroundColor Green
            } 
        "Modify" {
            Write-Host "Modifiyng ReadOnly property in $sSiteCollection to $sReadOnlyMode" -ForegroundColor Green
            $spSite.ReadOnly=$sReadOnlyMode            
            Write-Host "Value for ReadOnly property: " $spSite.ReadOnly -ForegroundColor Green            
            }         
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor Green          
            }
        }
   	
        $spSite.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
ReadModify-SPSiteProperties -sSiteCollection "http://c4968397007:90" -sOperationType "Read"
ReadModify-SPSiteProperties -sSiteCollection "http://c4968397007:90" -sOperationType "Modify" -sReadOnlyMode $false
ReadModify-SPSiteProperties -sSiteCollection "http://c4968397007:90" -sOperationType "Read"
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell