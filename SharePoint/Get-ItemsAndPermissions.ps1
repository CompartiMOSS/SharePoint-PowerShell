<#
.SYNOPSIS
   Return all sites, webs and lists in a webapplication with the permission inheritance and the number of items with unique permissions.

.DESCRIPTION
   Return all sites, webs and lists in a webapplication with the permission inheritance and the number of items with unique permissions

.NOTES
   File Name: Get-ItemsAndPermissions.ps1
   Author   : Bart Kuppens
   Version  : 1.0

.PARAMETER WebApplication
   Specifies the URL of the Web Application.

.PARAMETER FieldDelimiter
   Specifies the delimiter which is used between the fields.

.EXAMPLE
   PS > .\Get-ItemsAndPermissions.ps1 -WebApplication http://intranet.sharepoint.local -FieldDelimiter ";" > c:\temp\sites.csv
#>
[CmdletBinding()]
param(
   [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$false,HelpMessage="Specifies the URL of the Web Application.")]
   [string]$WebApplication,
   [Parameter(Position=1,Mandatory=$true,ValueFromPipeline=$false,HelpMessage="Specifies the delimiter which is used between the fields.")]
   [string]$FieldDelimiter
)

# Load the SharePoint PowerShell snapin if needed
if ((Get-PSSnapin -Name Microsoft.SharePoint.Powershell -EA SilentlyContinue) -eq $null)
{
   Write-Host "Loading the SharePoint PowerShell snapin..."
   Add-PSSnapin Microsoft.SharePoint.Powershell
}

$webapp = Get-SPWebApplication $WebApplication -ea silentlyContinue
if ($webapp -eq $null)
{
   Write-Host -ForegroundColor Red "The URL $WebApplication is not a valid webapplication"
   exit
}
$sites = Get-SPSite -WebApplication $webapp -Limit All
$header = [string]::Format("Site{0}Web{0}List{0}# Items{0}Break Permission Inheritance{0}# Items with unique permissions", $FieldDelimiter)

Write-Output $header
foreach ($site in $sites)
{
   $siteUrl = $site.Url
   $webs = $site.AllWebs
   $detail = [string]::Format("$siteUrl{0}{0}{0}{0}{0}", $FieldDelimiter)
   Write-Output $detail
   foreach ($web in $webs)
   {
      $webUrl = $web.Url
      $lists = $web.Lists
      $webBreakInheritance = $web.HasUniqueRoleAssignments
      $detail = [string]::Format("$siteUrl{0}$webUrl{0}{0}{0}$webBreakInheritance{0}", $FieldDelimiter)
      Write-Output $detail
      foreach ($list in $lists)
      {
         $items = $list.Items
         $listItemCount = $items.Count
         $listBreakInheritance = $list.HasUniqueRoleAssignments
         $i = 0
         try
         {
            foreach ($item in $items)
            {
               if ($item.HasUniqueRoleAssignments)
               {
                  $i++
               }
            }
         }
         catch {}
         $detail = [string]::Format("$siteUrl{0}$webUrl{0}$($list.Title){0}$listItemCount{0}$listBreakInheritance{0}$i", $FieldDelimiter)
         Write-Output $detail
      }
      $web.Dispose()
   }
   $site.Dispose()
}