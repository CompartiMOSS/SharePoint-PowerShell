############################################################################################################################################
# Script que obtiene la configuración de MUI de todas las Web Applications
# Parametros necesarios:
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

function GetMUIInAFarm
{  
    try
    {        
	    #Obtenemos todos los sitios
	    $spWebs = (Get-SPSite -limit all | Get-SPWeb -Limit all -ErrorAction SilentlyContinue) 

        #Para cada sitio de SharePoint    
        foreach($spWeb in $spWebs) 
        { 
            Write-Host "Sitio de SharePoint "$spWeb.url -ForegroundColor Green            
			Write-Host " - IsMultiLingual "$spWeb.IsMultiLingual

			$supportedCultures = $spWeb.SupportedUICultures;
			foreach ($culture in $supportedCultures)
			{
				Write-Host " - Culture "$culture.Name
			}

            $spWeb.Dispose() 
        }         	
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
GetMUIInAFarm 
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell