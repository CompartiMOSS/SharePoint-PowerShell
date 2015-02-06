############################################################################################################################################
#Script that allows to activate a Sandbox solution in SharePoint Online
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: SharePoint Online Site Collection.
#  -> $sSiteCollectionRelativePath: Site Collection Relative Path.
#  -> $sSolutionName: Sandbox solution name.
#  -> $sSolutionFile: Sandbox solution file.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to activate a Sandbox solution in SharePoint Online
function Activate-SandboxSolution
{
    param ($sSiteColUrl,$sUserName,$sPassword,$sSiteCollectionRelativePath,$sSolutionName,$sSolutionFile)
    try
    { 
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Publishing.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      
    
        $spoDesignPackageInfo=New-Object Microsoft.SharePoint.Client.Publishing.DesignPackageInfo
        $spoDesignPackageInfo.PackageGuid=[GUID]::Empty
        $spoDesignPackageInfo.MajorVersion=1
        $spoDesignPackageInfo.MinorVersion=1
        $spoDesignPackageInfo.PackageName=$sSolutionName
        $sSolutionRelativePath=$sSiteCollectionRelativePath + "_catalogs/solutions/" + $sSolutionFile
        $sSolutionRelativePath
        #[Microsoft.SharePoint.Client.Publishing.DesignPackage] | Get-Member -Static
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Activating the Sandbox Solution in the Solution Gallery!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spoDesignPackage=[Microsoft.SharePoint.Client.Publishing.DesignPackage]
        $spoDesignPackage::Install($spoCtx,$spoCtx.Site,$spoDesignPackageInfo,$sSolutionRelativePath)      
        $spoCtx.ExecuteQuery()
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Sandbox Solution successfully activated in the Solution Gallery!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteColUrl = "https://<Your_SPO_Site_Collection>" 
$sUserName = "<Your_SPO_User>" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<Your_SPO_Pasword>" -asplaintext -force
$sSolutionName="<Sandbox_Solution_Name>"
$sSolutionFile="<Sandbox_Solution_File>"
$sSiteCollectionRelativePath="/sites/<SiteCollectionName>/"

Activate-SandboxSolution -sSiteColUrl $sSiteColUrl -sUserName $sUserName -sPassword $sPassword -sSiteCollectionRelativePath $sSiteCollectionRelativePath -sSolutionName $sSolutionName -sSolutionFile $sSolutionFile