############################################################################################################################################
# Script that allows to find the SharePoint 2013 Search Index location
# Required Parameters: 
#    -> N/A
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that finds the Search Index File Location
function Find-SearchIndex
{ 
    try
    {
        $spSearchServiceIntance = Get-SPEnterpriseSearchServiceInstance
        Write-Host "SharePoint Search Index is located at " $spSearchServiceIntance.Components.IndexLocation -ForegroundColor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
Find-SearchIndex
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell