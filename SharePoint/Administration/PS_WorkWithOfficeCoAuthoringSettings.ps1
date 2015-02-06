###############################################################################################################
# This script allows to work with the Maximum Number of Co-Authors in Office documents.
# Required Parameters: 
#    ->$sSiteCollectionUrl: Site Collection where we want to do the CAML Query.
#    ->$sOperationType: Operation type to be done with the Maximum Number of Co-Authors in Office documents.
#    ->$iMaxCoAuthorsNumber: Maximum number of co-authors to be configured for a Web Application.
###############################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to work with the Maximum Number of Co-Authors in Office documents
function WorkWithOfficeCoAuthorsNumber
{
    param ($sSiteCollectionUrl,$sOperationType,$iMaxCoAuthorsNumber)
    try
    {

        $spSite=Get-SPSite -Identity $sSiteCollectionUrl

#$mysite.WebApplication.WebService.CoauthoringMaxAuthors = <MaxAuthors>
#$mysite.WebApplication.WebService.Update()

        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "The maximum number of Co-Authors for an Office Document is " $spSite.WebApplication.WebService.CoauthoringMaxAuthors "!!" -ForegroundColor Green 
            } 
        "Update" {
            Write-Host "Updating the maximum number of co-authors to $iMaxCoAuthorsNumber " -ForegroundColor Green                 
            $spSite.WebApplication.WebService.CoauthoringMaxAuthors = $iMaxCoAuthorsNumber
            $spSite.WebApplication.WebService.Update()
            Write-Host "The maximum number of Co-Authors for an Office Document is " $spSite.WebApplication.WebService.CoauthoringMaxAuthors "!!" -ForegroundColor Green 
            }          
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
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
$sSiteCollectionUrl="http://<Site_Collection_Url>"
WorkWithOfficeCoAuthorsNumber -sSiteCollectionUrl $sSiteCollectionUrl -sOperationType "Read"
WorkWithOfficeCoAuthorsNumber -sSiteCollectionUrl $sSiteCollectionUrl -sOperationType "Update" -iMaxCoAuthorsNumber 88

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell