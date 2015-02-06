############################################################################################################################################
# Script that allows to export/import a Site.
# Required Parameters: 
#    ->$sSiteToExport: SharePoint Site to be Exported
#    ->$sSiteToImport: SharePoint Site to be Imported
#    ->$sBackupPath: Path where the Backup is stored
#    ->$sOperationType: Operation Type (Backup or Restore)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that exports/imports a SharePoint Site
function ExportImportSharePointSite
{
    param ($sSiteToExport,$sSiteToImport,$sOperationType,$sBackupPath)
    try
    {
        switch ($sOperationType) 
        { 
        "Export" {
            Write-Host "Doing the export for $sSiteToExport !!" -ForegroundColor Blue
            Export-SPWeb -Identity $sSiteToExport -Path $sBackupPath -Force -Confirm:$false
            Write-Host "Export operation for $sSiteToExport successfully completed!!" -ForegroundColor Blue

            } 
        "Import" {
            Write-Host "Doing the import for $sSiteToImport" -ForegroundColor Blue
            New-SPWeb -Url $sSiteToImport -Template "STS#0" -Language 3082
            Import-SPWeb -Identity $sSiteToImport -Path $sBackupPath
            Write-Host "Import Operation for $sSiteToImport successfully completed!!" -ForegroundColor Blue
            }         
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }
   	
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sSiteToExport="http://<Site_To_Export>/"
$sSiteToImport="http://<Site_To_Import>"
$sBackupPath="<Backup_Path>\<Backup_File>.cmp"
#Export
ExportImportSharePointSite -sSiteToExport $sSiteToExport -sBackupPath $sBackupPath -sOperationType "Export"

#Import
ExportImportSharePointSite -sSiteToImport $sSiteToImport -sBackupPath $sBackupPath -sOperationType "Import"
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell