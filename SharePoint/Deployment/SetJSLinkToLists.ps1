############################################################################################################################################
# Script que establece la URL del fichero JSLink para todas las listas de un Template en un sitio
# Parametros necesarios:
#   -> $sSiteUrl: Url del sitio del que se desean obtener las listas (si aplica)
#   -> $sTemplate: Id de la Plantilla de lista
# Referencia: http://sharepointrelated.com/2011/11/28/get-all-sharepoint-lists-by-using-powershell/
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

$editJSLink = "~sitecollectionlayouts/vitrall/js/jquery.min.js|~sitecollectionlayouts/vitrall/jslink/documenteditform.js"
$dispJSLink = "~sitecollectionlayouts/vitrall/js/jquery.min.js|~sitecollectionlayouts/vitrall/jslink/documentsform.js"


function SetJSLink
{  
    param ($sSiteUrl,$sTemplate)
    try
    {        
	    #Un sitio o todos?
	    if(!$sSiteUrl) 
	    { 
	        #Obtenemos todos los sitios
	        $spWebs = (Get-SPSite -limit all | Get-SPWeb -Limit all -ErrorAction SilentlyContinue) 
	    } 
	    else 
	    { 
    	    #Obtenemos sólo el sitio indicado
	        $spWebs = Get-SPWeb $sSiteUrl 
	    }        
        #Para cada sitio de SharePoint    
        foreach($spWeb in $spWebs) 
        { 
            #Accedemos a todas las listas de cada sitio
            $lLists = $spWeb.Lists    
            Write-Host "Sitio de SharePoint "$spWeb.url -ForegroundColor Green            
            foreach($lList in $lLists) 
            {
                if ($lList.BaseTemplate -eq $sTemplate)
                {
                    $wpm = $spWeb.GetLimitedWebPartManager($lLists.DefaultEditFormUrl,[System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
                    $webpart = $wpm.WebParts[0]
                    $webpart.JSLink = $editJSLink

                    $wpm.SaveChanges($webpart)

                    $wpm = $spWeb.GetLimitedWebPartManager($lLists.DefaultDisplayFormUrl,[System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
                    $webpart = $wpm.WebParts[0]
                    $webpart.JSLink = $dispJSLink

                    $wpm.SaveChanges($webpart)
                } 
            } 
            $spWeb.Dispose() 
        }         	
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global

#Calling the function
SetJSLink -sSiteUrl "http://sf1" -sTemplate "DocumentLibrary"
SetJSLink -sSiteUrl "http://sf1" -sTemplate "40000"

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell