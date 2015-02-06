############################################################################################################################################
# Script para el borrado/creación de un Site Collection
# Parámetros necesarios: 
#       - URL del sitio
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

function Create-Site
{
    param($sWebUrl)  
    try
    {
        New-SPSite  -url $sWebUrl -template STS#0  -OwnerAlias “pharus\alberto.diaz“  -Name “Vitrall”
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

function Delete-Site
{
    param($sWebUrl)  
    try
    {
        Remove-SPSite -Identity $sWebUrl -Confirm:$False
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}


Start-SPAssignment –Global

$sWebUrl="http://sf1"

Delete-Site -sWebUrl $sWebUrl

Create-Site -sWebUrl $sWebUrl

Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell