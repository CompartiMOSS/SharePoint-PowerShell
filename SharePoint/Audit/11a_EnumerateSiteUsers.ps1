############################################################################################################################################
# Script que enumera todos los usuarios de las colecciones de sitios y sitios de la granja
# Parametros necesarios: N/A
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

function GetAllUsersInAFarm
{  

    try
    {  
        $sPath = Get-Location
        $spSites = Get-SPSite

        foreach ($spSite in $spSites) {
            [array]$spUsers = $null
            $sSiteName = $spSite.RootWeb.Title
            $sFileLocation = $ScriptDir + "\" + "$path\$sSiteName" + "_Users.csv"
            write-host -foregroundcolor green "Site Collection: "$spSite.RootWeb.Title "..."
            foreach ($spWeb in $spSite.AllWebs) 
            {
                write-host -foregroundcolor blue "--Web Site:" $spWeb.Title "..."
                foreach ($spGroup in $spWeb.groups)
                {
	                write-host -foregroundcolor yellow "----Collecting users from group:"$spGroup.Name "..."
	                foreach($spUser in $spGroup.users) 
                    {	  
	                    $spUsers = new-object psobject
	                    $spUsers | add-member noteproperty -name "User" -value $spUser
	                    $spUsers | add-member noteproperty -name "Display Name" -value $spUser.DisplayName
	                    $spUsers | add-member noteproperty -name "Groups" -value $spGroup.name
	                    $spUsers | add-member noteproperty -name "SiteName" -value $spSite.RootWeb.Title
	                    $spUsers | add-member noteproperty -name "SiteURL" -value $spSite.Url
	                    $spUsers | Add-Member NoteProperty -name "WebName" -value $spWeb.Title
	                    $spUsers | add-member noteproperty -name "WebURL" -value $spWeb.Url
	                    $spAllUsers += $spUsers
    	            }
                  }
                $spWeb.Dispose()
            }
            $spAllUsers | export-csv -path $sFileLocation -notype
            $spAllUserss = $null
            $spSite.Dispose()
        }

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
GetAllUsersInAFarm
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell