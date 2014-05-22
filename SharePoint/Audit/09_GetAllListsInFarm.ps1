############################################################################################################################################
# Script que obtiene todas las listas de una granja
# Parametros necesarios:
#   -> $sSiteUrl: Url del sitio del que se desean obtener las listas (si aplica)
#   -> $sExportFileName: Nombre del archivo donde se van a exportar las listas inventariadas
# Referencia: http://sharepointrelated.com/2011/11/28/get-all-sharepoint-lists-by-using-powershell/
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

function GetAllListsInAFarm
{  
    param ($sSiteUrl,$sExportFileName)
    try
    {        
        $sOutputPath=$ScriptDir + "\" + $sExportFileName
        [array]$lListsInSite = $null        
    	$iWebCount = 0 
	    $iListCount = 0
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
                $iListCount +=1   
                Write-Host " – "$lList.Title          
                $lListsInSite = new-object psobject
	        $lListsInSite | add-member noteproperty -name "Sitio de SharePoint" -value $spWeb.Url
                $lListsInSite | add-member noteproperty -name "Lista" -value $lList.Title
                $AllLists += $lListsInSite          
            } 
            $iWebCount +=1 
            $spWeb.Dispose() 
        }         	
	    Write-Host "# de sitios de SharePoint accedidos: " $iWebCount 
	    Write-Host "# de listas:"$iListCount
        #Guardamos en disco
        $AllLists | export-csv -path $sOutputPath -notype
        $AllLists = $null
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sExportFileName="ListsInFarm.txt"
GetAllListsInAFarm -sExportFileName $sExportFileName 
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell