#UPLOADING

$sourceVHD = "D:\StorageDemos\myvhd.vhd"
$destinationVHD = "https://mwwestus1.blob.core.windows.net/uploads/myvhd.vhd"
 
Add-AzureVhd -LocalFilePath $sourceVHD -Destination $destinationVHD -NumberOfUploaderThreads 5

# Register as a plan old data disk 
Add-AzureDisk -DiskName 'mydatadisk' -MediaLocation $destinationVHD -Label 'mydatadisk'

# Register as a plan old data disk 
Add-AzureDisk -DiskName 'myosdisk' -MediaLocation $destinationVHD -Label 'myosdisk' -OS Windows # or Linux


#DOWNLOADING
select-azuresubscription "mysubscriptionname"
 
$sourceVHD = "https://mwwestus1.blob.core.windows.net/uploads/mydatadisk.vhd"
$destinationVHD = "D:\StorageDemos\mydatadisk-downloaded.vhd"
 
Save-AzureVhd -Source $sourceVHD -LocalFilePath $destinationVHD -NumberOfThreads 5
