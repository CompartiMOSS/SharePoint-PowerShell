############################################################################################################################################
# This script allows to manage themes in a SharePoint site
# Required parameters
#   ->$siteUrl: Site Collection Url
#   ->$sThemeName: Name of the theme to be applied
#   ->$spColorRelativePath: Relative path for the palette color
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Required variables
$sSiteUrl = “http://c4968397007:90/”

#Definiton of the function that allows to manage SharePoint Themes
function Manage-SiteTheme
{
    param ($sOperationType,$sThemeName,$spColorRelativePath)   
    try
    {
        $spSite = Get-SPSite -Identity $sSiteUrl
        $spWeb = $spSite.OpenWeb()
        
        #Operation Type
        switch ($sOperationType) 
        { 
        "List" {
            Write-Host "Getting available themes in $spSite" -ForegroundColor Green
            $spThemesCatalogue = $spWeb.GetCatalog([Microsoft.SharePoint.SPListTemplateType]::DesignCatalog)
            $spQuery=New-Object Microsoft.SharePoint.SPQuery
            foreach ($spItem in $spThemesCatalogue.GetItems($spQuery)) {
                Write-Host "Theme: " $spItem["Name"].ToString() " - Palette Color Url: " $spItem["ThemeUrl"].ToString()
                }
            } 
        "Remove" {
            Write-Host "Removing the applied theme in $spWeb" -ForegroundColor Green
            $spTheme = [Microsoft.SharePoint.Utilities.ThmxTheme]::RemoveThemeFromWeb($spWeb,$false)
            $spWeb.Update()
            }
        "Change" {
            Write-Host "Changing theme for $spWeb" -ForegroundColor Green
            [Microsoft.SharePoint.SPSecurity]::RunWithElevatedPrivileges({ 
                $spFile=$spWeb.GetFile($sSiteUrl + $spColorRelativePath)
                $spTheme=[Microsoft.SharePoint.Utilities.SPTheme]::Open($sThemeName, $spFile)     
                $spTheme.ApplyTo($spWeb, $true)
                })
            }           
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }
        #Disposing SPSite & SPWebObjects
        $spWeb.Dispose()
        $spSite.Dispose()        
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sThemeName="Naranja"
$spColorRelativePath= "_catalogs/theme/15/palette015.spcolor"
Manage-SiteTheme -sOperationType "Change" -sThemeName $sThemeName -spColorRelativePath $spColorRelativePath
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell