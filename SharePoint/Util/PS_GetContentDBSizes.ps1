############################################################################################################################################
# Script that gets content databases sizes for all the web applications in a SharePoint Farm
# Parameters: N/A
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Function that gets the size of all the content databases 
function Get-ContentDBSizes
{  
    try
    {

        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        { 
            #$spWebApp.Name
            $ContentDatabases = $spWebApp.ContentDatabases
            foreach($ContentDatabase in $ContentDatabases) 
            {     
                $ContentDatabaseSize = [Math]::Round(($ContentDatabase.disksizerequired/1GB),2)
                $ContentDatabaseInfo= $spWebApp.DisplayName + "," + $ContentDatabase.Name + "," + $ContentDatabaseSize + " GB" 
                $ContentDatabaseInfo
                #Write-Host " * "  $spWebApp.DisplayName "-" $ContentDatabase.Name ": " $ContentDatabaseSize " GB"
            } 
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}


Start-SPAssignment –Global
Get-ContentDBSizes > ContentDBs.csv

Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell