$webapps = Get-SPWebApplication 
foreach($webapp in $webapps) 
{ 
    Write-Host $webapp.Name
    $webapp.GrantAccessToProcessIdentity("urbaser\svcExcel")
} 