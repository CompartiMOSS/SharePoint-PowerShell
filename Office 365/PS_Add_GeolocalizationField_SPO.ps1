############################################################################################################################################
#Script that adds a geolocalization field to a list in a SharePoint Online site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site Url
#  -> $sListName: Name of the list where the geolocalization field is going to be added.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add a geolocalization field to a list in SharePoint Online
function Add-GeolocalizationFieldSPO
{
    param ($sSiteUrl,$sUserName,$sPassword,$sListName)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding a gelocalization field to $sListName !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green        
        
        $spoList=$spoCtx.Web.Lists.GetByTitle($sListName)        
        $FieldOptions=[Microsoft.SharePoint.Client.AddFieldOptions]::AddToAllContentTypes
        $spoList.Fields.AddFieldAsXml("<Field Type='Geolocation' DisplayName='Location'/>",$true,$FieldOptions)
        $spoList.Update()
        $spoCtx.ExecuteQuery()
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<SPO_Site_Url>" 
$sUserName = "<SPOUser>@<SPODomain>.onmicrosoft.com" 
$sListName= "<ListName>"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<SPOPassword>" -asplaintext -force

Add-GeolocalizationFieldSPO -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sListName $sListName

