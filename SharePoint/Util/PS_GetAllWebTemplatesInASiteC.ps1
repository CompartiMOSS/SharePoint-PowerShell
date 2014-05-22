############################################################################################################################################
# Script that gets all web templates available for creating new sites
# Required parametes:
#   -> $sSiteUrl: Url of the site collection
#   -> $iCulture: Locale ID for which we want to get all web templates
#   -> $sExportFileName: Name of the file where the Web Templates information is going to be exported.
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

#Definition of the function that gets all the Web Templates for a site collection
function GetAllWebTemplates
{  
    param ($sSiteUrl,$iCulture,$sExportFileName)
    try
    {   
        $sOutputPath=$ScriptDir + "\" + $sExportFileName 
        [array] $WebTemplateInSite = $null
        $spSiteC= Get-SPSite -Identity $sSiteUrl
        $cCulture= [System.Int32]::Parse($iCulture)
        $spTemplates= $spSiteC.GetWebTemplates($cCulture)
        #Reading available Web Templates
        foreach ($spTemplate in $spTemplates)
        {
            Write-Host " – "$spTemplate.Title
            $WebTemplateInSite = new-object psobject
	        $WebTemplateInSite | add-member noteproperty -name "Template Name" -value $spTemplate.Name
            $WebTemplateInSite | add-member noteproperty -name "Template Title" -value $spTemplate.Title
            $AllWebTemplates += $WebTemplateInSite     
        }
        #Exporting the information
        $AllWebTemplates | export-csv -path $sOutputPath -notype
        $AllWebTemplates = $null
        $spSiteC.Dispose()    
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sExportFileName="WebTemplatesInSite.txt"
GetAllWebTemplates -sSiteUrl "<Site_Collection_Url>" -iCulture 1033 -sExportFileName $sExportFileName
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell