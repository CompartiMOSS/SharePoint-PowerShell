$webapps = Get-SPWebApplication 
foreach($webapp in $webapps) 
{ 
    Write-Host $webapp.Name
    $webapp.GrantAccessToProcessIdentity("domain\svcExcel")
} 