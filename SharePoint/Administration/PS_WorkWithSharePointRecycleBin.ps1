############################################################################################################################################
# This script allows to play with SharePoint Recycle Bin
# Required Parameters: 
#    ->$sSiteCollection: Site Collection where we want to play with the recycle bin
#    ->$sOperationType: Operation Type when working with the recycle bin
#    ->$sUser: SharePoint User to whom we want to query deleted files that are in the recycle bin
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that restores de deleted Site Collection
function WorkWithSPRecycleBin
{
    param ($sSiteCollection,$sOperationType,$sUser)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollection
        
        #Operation Type
        switch ($sOperationType) 
        { 
        "All" {
            Write-Host "Accessing to $sSiteCollection recycle bin. Listing all deleted items!!" -ForegroundColor Green
            $spSite.RecycleBin | sort DirName | select Title, ItemType, DirName, ItemState 
            } 
        "Sites" {
            Write-Host "Accessing to $sSiteCollection recycle bin. Listing all deleted sites!!" -ForegroundColor Green
            $spSite.Recyclebin | where {$_.ItemType -eq "Web"} | sort DirName | select Title, ItemType, DirName, ItemState      
            } 
        "Other" {
            Write-Host "Accessing to $sSiteCollection recycle bin. Listing other deleted items!!" -ForegroundColor Green
            $site.RecycleBin | where { $_.ItemType -ne "File" -and $_.ItemType -ne "ListItem" } | sort DirName | select Title, ItemType, DirName, ItemState 
            }
         "ByUser" {
            Write-Host "Accessing to $sSiteCollection recycle bin. Listing items deleted by $sUser!!" -ForegroundColor Green
            $spSite.RecycleBin | where {$_.DeletedBy -like $sUser}  | sort DirName | select Title, ItemType, DirName, ItemState 
            }
         "RestoreFiles" {
            Write-Host "Restoring files from recycle bin in $sSiteCollection" -ForegroundColor Green
            $spItemsToRestore=$spSite.Recyclebin | where {$_.Itemtype -eq "File" -and $_.Title -match ".jpg"} | sort DirName | select Title, ItemType, DirName, ItemState, ID                            
            foreach ($spItemToRestore in $spItemsToRestore){
                Write-Host "Restaurando " $spItemToRestore.Title
                $spSite.RecycleBin.Restore($spItemsToRestore.ID)
                }                
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
$sSiteCollection="http://<SiteCollection>"
WorkWithSPRecycleBin -sSiteCollection $sSiteCollection -sOperationType "All"
WorkWithSPRecycleBin -sSiteCollection $sSiteCollection -sOperationType "Sites"
WorkWithSPRecycleBin -sSiteCollection $sSiteCollection -sOperationType "Other"
WorkWithSPRecycleBin -sSiteCollection $sSiteCollection -sOperationType "ByUser" -sUser "<SharePoint_User>"
WorkWithSPRecycleBin -sSiteCollection $sSiteCollection -sOperationType "RestoreFiles"
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell