$webapps = Get-SPWebApplication 
foreach($webapp in $webapps) 
{ 
    Write-Host $webapp.Name
    .\Get-ItemsAndPermissions.ps1 -WebApplication $webapp.Url -FieldDelimiter ";" > c:\encamina\sites$webapp.Name.csv
} 

