############################################################################################################################################
# Script that allows to execute the cmdlet Test-SPContentDatabase against all the Content Databases in a SharePoint farm
# Required parameters: 
#   -> $SServerInstance: Name of the server where content databases are living.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Function that allows to execute Test-SPContentDatabase agains all the Content Databases in a SharePoint Farm
function Execute-TestContentDatabase
{  
    param ($sServerInstance)
    try
    {
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        { 
            $ContentDatabases = $spWebApp.ContentDatabases
            foreach($ContentDatabase in $ContentDatabases) 
            {   
                Test-SPContentDatabase –Name $ContentDatabase.Name -ServerInstance $sServerInstance -WebApplication $spWebApp.Url
            } 
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
Execute-TestContentDatabase -sServerInstance "<Sever_Instance>"
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell