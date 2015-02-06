############################################################################################################################################
# This script allows to work with SharePoint property bags at the Site Collection Level
# Required Parameters: 
#    ->$sSiteCollection: Site Collection where we want to do add a property bag.
#    ->$sOperationType: Operation type to be done with the property bag - Create - Update - Delete.
#    ->$sPropertyBagKey: Key for the property bag to be added.
#    ->$sPropertyBagValue: Value for the property bag addded.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create, update and remove a property bag
function WorkWithSiteCollectionPropertyBags
{
    param ($sSiteCollection,$sOperationType,$sPropertyBagKey,$sPropertyBagValue)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollection
        $spwWeb=$spSite.OpenWeb()
        switch ($sOperationType) 
        { 
        "Create" {
            Write-Host "Adding property bag $sPropertyBagKey to $sSiteCollection !!" -ForegroundColor Green                        
            $spwWeb.AllProperties.Add($sPropertyBagKey,$sPropertyBagValue)           
            $spwWeb.Update()            
            $sPropertyBag=$spwWeb.AllProperties[$sPropertyBagKey]
            Write-Host "Property bag $sPropertyBagKey has the value $sPropertyBag" -ForegroundColor Green
            } 
        "Read" {
            Write-Host "Reading property bag $sPropertyBagKey" -ForegroundColor Green                 
            $sPropertyBag=$spwWeb.AllProperties[$sPropertyBagKey]
            Write-Host "Property bag $sPropertyBagKey has the value $sPropertyBag" -ForegroundColor Green
            }
        "Update" {
            $sPropertyBag=$spwWeb.AllProperties[$sPropertyBagKey]
            Write-Host "Property bag $sPropertyBagKey has the value $sPropertyBag" -ForegroundColor Green        
            Write-Host "Updating property bag $sPropertyBagKey for $sSiteCollection" -ForegroundColor Green            
            $spwWeb.AllProperties[$sPropertyBagKey]="SPSiteColPBagUpdatedValue_2"                        
            $sPropertyBag=$spwWeb.AllProperties[$sPropertyBagKey]
            Write-Host "Property bag $sPropertyBagKey has the value $sPropertyBag" -ForegroundColor Green
            } 
        "Delete" {
            Write-Host "Deleting property bag $sPropertyBagKey" -ForegroundColor Green                                    
            $spwWeb.AllProperties.Remove($sPropertyBagKey)            
            $spwWeb.Update()            
            $sPropertyBag=$spwWeb.AllProperties[$sPropertyBagKey]
            Write-Host "Property bag $sPropertyBagKey has the value $sPropertyBag" -ForegroundColor Green                
            }           
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }
        $spwWeb.Dispose()
        $spSite.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sSiteCollection="http://<YourSiteCollection>"
$sPropertyBagKey="SPSiteColPBagKey_2"
$sPropertyBagValue="SPSiteColPBagValue_2"
#WorkWithSiteCollectionPropertyBags -sSiteCollection $sSiteCollection -sOperationType "Delete" -sPropertyBagKey $sPropertyBagKey -sPropertyBagValue $sPropertyBagValue
WorkWithSiteCollectionPropertyBags -sSiteCollection $sSiteCollection -sOperationType "Create" -sPropertyBagKey $sPropertyBagKey -sPropertyBagValue $sPropertyBagValue
WorkWithSiteCollectionPropertyBags -sSiteCollection $sSiteCollection -sOperationType "Read" -sPropertyBagKey $sPropertyBagKey -sPropertyBagValue $sPropertyBagValue
WorkWithSiteCollectionPropertyBags -sSiteCollection $sSiteCollection -sOperationType "Update" -sPropertyBagKey $sPropertyBagKey -sPropertyBagValue $sPropertyBagValue
WorkWithSiteCollectionPropertyBags -sSiteCollection $sSiteCollection -sOperationType "Delete" -sPropertyBagKey $sPropertyBagKey -sPropertyBagValue $sPropertyBagValue


Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell