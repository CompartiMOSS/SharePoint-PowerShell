############################################################################################################################################
# Script para la activación de una Feature
# Parámetros necesarios: 
#       - Identidad de la Feature
#       - URL del sitio
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Definición de la función que obtiene el tamaño de las BD's de contenidos
function Activate-Feature
{
    param($sIdentity,$sWebUrl)  
    try
    {
        Enable-SPFeature -identity $sIdentity -URL $sWebUrl
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sWebUrl="http://sf1"

$sIdentity="c3e7d105-d10b-4b81-a3f6-b1ea1b8974c0"
Activate-Feature -sIdentity $sIdentity -sWebUrl $sWebUrl

$sIdentity="b747d2ea-19de-41e3-b165-1b4772c85d32"
Activate-Feature -sIdentity $sIdentity -sWebUrl $sWebUrl

Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell