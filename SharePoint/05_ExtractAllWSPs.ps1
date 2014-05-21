############################################################################################################################################
# Script que extrae todos los WSPs de la granja
# Parámetros necesarios: N/A
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Función que permite extraer todos los WSPs del contenedor global de soluciones de SharePoint
function GetAllWSPs
{    
    write-host "Iniciada la extracción de los WSPs del contenedor global de la granja Granja ...." -foregroundcolor yellow 
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