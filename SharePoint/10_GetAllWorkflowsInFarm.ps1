#http://sharepointrelated.com/2011/11/21/get-all-workflows-in-all-sites-and-lists/
param ([boolean] $writeToFile = $true)
#List all workflows in farm
 Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

#If boolean is set to true, you can specify an outputlocation, to save to textfile.

if($writeToFile -eq $true)
 {
 $outputPath = Read-Host "Outputpath (e.g. C:\directory\filename.txt)"
}
#Counter variables
 $webcount = 0
 $listcount = 0
 $associationcount = 0

#Grab all webs
<#
 $spSite=Get-SPSite -Limit All
 $webs+=$spSite.Allwebs #| % {$webs += $_.Allwebs}#>
 $webs=Get-SPSite -Limit All | Get-SPWeb -Limit All
 if($webs.count -ge 1)
 {
 foreach($web in $webs)
 {
#Grab all lists in the current web
 $lists = $web.Lists
 foreach($list in $lists)
 {
 $associations = @()
   #Get all workflows that are associated with the current list
            foreach($listassociation in $list.WorkflowAssociations)
 {
 $associations += $($listassociation.name)
 }
 $listcount +=1
 if($associations.count -ge 1)
 {
 Write-Host "Website" $web.url -ForegroundColor Green
 Write-Host "  List:" $list.Title -ForegroundColor Yellow
 foreach($association in $associations){Write-Host "   -" $association}

if($WriteToFile -eq $true)
 {
 Add-Content -Path $outputPath -Value "Website $($web.url)"
Add-Content -Path $outputPath -Value "  List: $($list.Title)"
foreach($association in $associations){Add-Content -Path $outputPath -Value "   -$association"}
Add-Content -Path $outputPath -Value "`n"
}
 }
 }
 $webcount +=1
 $web.Dispose()
 }
#Show total counter for checked webs & lists
 Write-Host "Amount of webs checked:" $webcount
 Write-Host "Amount of lists checked:" $listcount
 $webcount = "0"
 }
 else
 {
 Write-Host "No webs retrieved, please check your permissions" -ForegroundColor Red -BackgroundColor Black
 $webcount = "0"
 }
