############################################################################################################################################
# Script that allows to get all the lists in a SharePoint Online site using REST
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sRESTUrl: API REST Url.
#  -> $WebRMehod: WebRequestMethod to use
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"


#Definition of the function that gets all the lists in a SharePoint Online Site using REST
function Get-SPListsUsingRESTAPI
{
    param ($sRESTUrl,$sUserName,$sPassword, $WebRMethod)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the list in a SharePoint Online Site using REST" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"        

        $spCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)
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
$sRESTUrl = "https://<SharePoint_Online_Site_Url/_api/web/lists" 
$sUserName = "<SharePoint_Online_User>" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$WebRMethod=[Microsoft.PowerShell.Commands.WebRequestMethod]::Get

Get-SPListsUsingRESTAPI -sRESTUrl $sRESTUrl  -sUserName $sUserName -sPassword $sPassword -WebRMethod $WebRMethod
