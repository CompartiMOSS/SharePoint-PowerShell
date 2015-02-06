############################################################################################################################################
# Script that allows to get all the lists in a SharePoint site using REST
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sDomain: AD Domain for the user.
#  -> $sRESTUrl: API REST Url.
#  -> $WebRMehod: WebRequestMethod to use
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the lists in a SharePoint Site using REST
function Get-SPListsUsingRESTAPI
{
    param ($sRESTUrl,$sUserName,$sPassword, $sDomain, $WebRMethod)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the lists in a SharePoint Site using REST" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
            
        $spCredentials = New-Object System.Net.NetworkCredential($sUserName,$sPassword,$sDomain)  
        $spWebRequest = [System.Net.WebRequest]::Create($sRESTUrl)
        $spWebRequest.Credentials = $spCredentials
        $spWebRequest.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
        $spWebRequest.Accept = "application/json;odata=verbose"
        $spWebRequest.Method=$WebRMethod
        $spWebResponse = $spWebRequest.GetResponse()
        $spRequestStream = $spWebResponse.GetResponseStream()
        $spReadStream = New-Object System.IO.StreamReader $spRequestStream
        $spData=$spReadStream.ReadToEnd()
        $spResults = $spData | ConvertFrom-Json
        $spLists=$spResults.d.results
        foreach($spList in $spLists)
        {
            Write-Host $spList.Title -ForegroundColor Green
        }                 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sRESTUrl = "http://<SharePointSite_Url>/_api/web/lists" 
$sUserName = "<SharePoint_User>" 
$sPassword ="<User_Password>" 
$sDomain="<AD_Domain>"
$WebRMethod=[Microsoft.PowerShell.Commands.WebRequestMethod]::Get


Get-SPListsUsingRESTAPI -sRESTUrl $sRESTUrl  -sUserName $sUserName -sPassword $sPassword -sDomain $sDomain -WebRMethod $WebRMethod

