--Tamaño Colecciones Sitios:
	Get-SPSite "http://demo2010a:200/" | select url, @{label="Size in MB";Expression={$_.usage.storage/1MB}}

--Tamaño BDs Contenidos:

$webapps = Get-SPWebApplication 
foreach($webapp in $webapps) 
{ 
    $webapp.Name
    $ContentDatabases = $webapp.ContentDatabases     
    foreach($ContentDatabase in $ContentDatabases) 
    {     
    $ContentDatabaseSize = [Math]::Round(($ContentDatabase.disksizerequired/1GB),2) 
    Write-Host " - " $ContentDatabaseSize
    } 
} 