############################################################################################################################################
# Script that allows to backup/restore all the WSPs in a Farm
# Required Parameters: 
#    ->$sSiteCollection: Site Collection where we are going to do the backup / restore
#    ->$sBackupPath: Path where the Backup is stored
#    ->$sOperationType: Operation Type (Backup or Restore)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that backup/restore all the WSPs in a farm!
function BackupRestoreSiteCollection
{
    param ($sItem,$sBackupPath,$sOperationType)
    try
    {
        switch ($sOperationType) 
        { 
        "Backup" {
            Write-Host "Doing the backup for the item $sItem !!" -ForegroundColor Blue
            Backup-SPFarm -BackupMethod Full -Directory $sBackupPath -Item $sItem -Confirm:$false
            Write-Host "Backup for the item $sItem successfully completed!!" -ForegroundColor Blue

            } 
        "Restore" {
            Write-Host "Doing the restore for the item $sItem" -ForegroundColor Blue
            Restore-SPFarm -RestoreMethod Overwrite -Directory $sBackupPath -Item $sItem -Percentage 10 -RestoreThreads 5 -Force
            Write-Host "Restore for the item $sItem successfully completed!!" -ForegroundColor Blue
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
BackupRestoreSiteCollection -sItem "farm\solutions" -sBackupPath "\\C4968397007\Backups\WSPs" -sOperationType "Restore"
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell
