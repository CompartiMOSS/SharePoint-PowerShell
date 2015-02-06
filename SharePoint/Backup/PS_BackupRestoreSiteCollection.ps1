############################################################################################################################################
# Script that allows to backup/restore a Site Collection
# Required Parameters: 
#    ->$sSiteCollection: Site Collection where we are going to do the backup / restore
#    ->$sBackupPath: Path where the Backup is stored
#    ->$sOperationType: Operation Type (Backup or Restore)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that restores de deleted Site Collection
function BackupRestoreSiteCollection
{
    param ($sSiteCollection,$sBackupPath,$sOperationType)
    try
    {
        switch ($sOperationType) 
        { 
        "Backup" {
            Write-Host "Doing the backup for $sSiteCollection !!" -ForegroundColor Blue
            Backup-SPSite -Identity $sSiteCollection -Path $sBackupPath -Force -Confirm:$false
            Write-Host "Backup for $sSiteCollection successfully completed!!" -ForegroundColor Blue

            } 
        "Restore" {
            Write-Host "Doing the restore for $sSiteCollection" -ForegroundColor Blue
            Restore-SPSite -Identity $sSiteCollection -Path $sBackupPath -Force
            Write-Host "Restore for $sSiteCollection successfully completed!!" -ForegroundColor Blue
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
BackupRestoreSiteCollection -sSiteCollection "http://c4968397007/sites/Intranet/" -sBackupPath "C:\Backups\Intranet.bak" -sOperationType "Restore"

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell