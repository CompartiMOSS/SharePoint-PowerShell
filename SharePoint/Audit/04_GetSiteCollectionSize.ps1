############################################################################################################################################
# Script que determina el espacio de almacenamiento de cada colección de sitios de la granjga
# Parámetros necesarios: N/A
############################################################################################################################################


If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Función que permite obtener todo el listado de Aplicaciones Web
function GetAllWebApplications
{ 
   
    write-host "Iniciada la extracción de las colecciones de sitios de cada Aplicación Web de la Granja ...." -foregroundcolor yellow 
    try
    {
        $spWebApps = Get-SPWebApplication -IncludeCentralAdministration
        foreach($spWebApp in $spWebApps) 
        {             
            GetAllSitecollectionsInfoInWebapplication -spWebApp $spWebApp  

        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
} 

#Función que obtiene la información de cada colección de sitios  
#http://kancharla-sharepoint.blogspot.com.es/2013/08/powershell-script-to-get-all-site.html  
function GetAllSitecollectionsInfoInWebapplication
{ 
    param ($spWebApp)
    try
    {       
        foreach($spSite in $spWebApp.Sites) 
        {            
            #Almacenamiento en MB
            [int]$usage = $spSite.usage.storage/1MB             
            $spWebApp.DisplayName + " , " + $spSite.RootWeb.Title + " , " + $spSite.Url + ", " + $usage + " MB"
        }  
    } 
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
 } 

Start-SPAssignment –Global
GetAllWebApplications > SiteCollection.csv
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell