############################################################################################################################################
# Get al the WSPs (Farm Solutions) stored in the SharePoint Global Solutions Catalog
# Parámetros necesarios: N/A
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Function that gets all the WSPs (Farm Solutions) stored in the farm
function GetAllWSPs
{    
    write-host "Started the process of extraction solutions in the global solutions catalog ...." -foregroundcolor yellow 
    try
    {
        $spSolutions = Get-SPSolution        
        foreach($spSolution in $spSolutions) 
        {             
            Write-Host "Extrayendo la solución $spSolution" -ForegroundColor Yellow
            $spSolutionFile=$spSolution.SolutionFile            
            $spSolutionFile.SaveAs($ScriptDir  + "\" + $spSolution.DisplayName)
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
} 

Start-SPAssignment –Global
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
GetAllWSPs
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell