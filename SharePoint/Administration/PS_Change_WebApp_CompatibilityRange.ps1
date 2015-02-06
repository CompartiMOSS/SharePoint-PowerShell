############################################################################################################################################
# Script that allows to change the compatibility level for an existing Web Application
# Required Parameters: 
#    ->$sWebApplicationUrl:Web Application Url
#    ->$sOption: Compatibility Level Option (NewVersion,OldVersions,AllVersions)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that changes the Compatibility Level for a Web Application
function Change-WebAppCompatibilityLevel
{
    param ($sWebApplicationUrl,$sOption)
    try
    {
        Write-Host "Changing compatibility level for $sWebApplicationUrl to $sOption !!" -ForegroundColor Green
        $spWebApp=Get-SPWebApplication $sWebApplicationUrl
        
        switch ($sOption) 
        { 
        "NewVersion" {
            $spWebApp.CompatibilityRange = [Microsoft.SharePoint.SPCompatibilityRange]::NewVersion
            } 
        "OldVersions" {
            $spWebApp.CompatibilityRange = [Microsoft.SharePoint.SPCompatibilityRange]::OldVersions
            }     
        "AllVersions" {
            $spWebApp.CompatibilityRange = [Microsoft.SharePoint.SPCompatibilityRange]::AllVersions
            }        
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor Green
            exit           
            }
        }
        $spWebApp.Update() 
        $spWebApp.CompatibilityRange
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
$sWebApplicationUrl="http://<WebApp_Url>"
$sOption="OldVersions"
Change-WebAppCompatibilityLevel -sWebApplicationUrl $sWebApplicationUrl -sOption $sOption
$sOption="AllVersions"
Change-WebAppCompatibilityLevel -sWebApplicationUrl $sWebApplicationUrl -sOption $sOption
$sOption="NewVersion"
Change-WebAppCompatibilityLevel -sWebApplicationUrl $sWebApplicationUrl -sOption $sOption

Stop-SPAssignment –Global


Remove-PSSnapin Microsoft.SharePoint.PowerShell