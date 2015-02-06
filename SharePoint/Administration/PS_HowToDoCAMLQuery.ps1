############################################################################################################################################
# This script allows to do a CAML query against a list / document library in a SharePoint Site
# Required Parameters: 
#    ->$sSiteCollection: Site Collection where we want to do the CAML Query
#    ->$sListName: Name of the list we want to query
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to do the CAML query
function DoCAMLQuery
{
    param ($sSiteCollection,$sListName)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollection
        $spwWeb=$spSite.OpenWeb()        
        $splList = $spwWeb.Lists.TryGetList($sListName) 
        if ($splList) 
        { 
            $spqQuery = New-Object Microsoft.SharePoint.SPQuery
            $spqQuery.Query = 
                "   <Where>
                    <Contains>
                        <FieldRef Name='FileLeafRef' />
                        <Value Type='File'>Farm</Value>
                    </Contains>
                </Where>"
            $spqQuery.ViewFields = "<FieldRef Name='FileLeafRef' /><FieldRef Name='Title' />"
            $spqQuery.ViewFieldsOnly = $true
            $splListItems = $splList.GetItems($spqQuery)

            $iNumber=1
            foreach ($splListItem in $splListItems)
            {
                write-host "File # $iNumber - Name: " $splListItem.Name " ," "Title:" $splListItem["Title"] -ForegroundColor Green
                $iNumber+=1
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
$sSiteCollection="http://<SiteCollectionUrl>"
$sListName="<DocumentLibraryName>"
DoCamlQuery -sSiteCollection $sSiteCollection -sListName $sListName
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell