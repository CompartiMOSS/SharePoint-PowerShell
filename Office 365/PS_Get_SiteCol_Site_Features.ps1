############################################################################################################################################
#Script that get all the features at the site collection and site level
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: SharePoint Online Site Collection
#  -> $sScope: Scope for the features we want to list
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to gell all the list of features at the Site Collection / Site Level
function Get-SPOFeatures
{
    param ($sSiteColUrl,$sUserName,$sPassword,$sGroup,$sScope)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      
        switch ($sScope) 
        { 
        "Site" {
            Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
            Write-Host "Features available at the Site Collection level for $sSiteColUrl !!" -ForegroundColor Green
            Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
            $spoSiteCol=$spoCtx.Site
            $spoFeatures=$spoSiteCol.Features
            $spoCtx.Load($spoFeatures)
            $spoCtx.ExecuteQuery()            
            foreach($spoFeature in $spoFeatures){
                $spoFeature.DefinitionId 
                }
            } 
        "Web" {
            Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
            Write-Host "Features available at the Site level for $sSiteColUrl !!" -ForegroundColor Green
            Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
            $spoSiteCol=$spoCtx.Web
            $spoFeatures=$spoSiteCol.Features
            $spoCtx.Load($spoFeatures)
            $spoCtx.ExecuteQuery()            
            foreach($spoFeature in $spoFeatures){
                $spoFeature.DefinitionId 
                }         
            }
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor Green            
            }
        }   	

        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<SPO_Site>" 
$sUserName = "<SPO_User>" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<SPO_PassWord>" -asplaintext -force

Get-SPOFeatures -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sScope "Site"
Get-SPOFeatures -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sScope "Web"

