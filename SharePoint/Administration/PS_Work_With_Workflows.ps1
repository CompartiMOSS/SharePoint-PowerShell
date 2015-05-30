############################################################################################################################################
# Script that allows to get the Workflow Service Status at both Web Application and Site Collection Level
# Required Parameters: 
# -> $sSiteCUrl: Site Collection Url
# -> $sWebAppUrl: Web Application Url
# -> $$sOperationTypee: Operation Type (SC = Site Collection - WA = Web Application)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Definición de la función de carga de datos en las listas auxiliares
function Get-WorkflowServiceStatus
{
    param ($sSiteCUrl,$sWebAppUrl,$sOperationType)

    try
    {
        switch ($sOperationType) 
        { 
        "SC" {
            Write-Host "Getting Workflow Status for Site Collection $sSiteCUrl" -ForegroundColor Green                        
            Get-SPWorkflowConfig -SiteCollection $sSiteCUrl
            } 
        "WA" {
            Write-Host "Getting Workflow Status for Web Application $sWebAppUrl" -ForegroundColor Green              
            Get-SPWorkflowConfig -WebApplication $sWebAppUrl
            }        
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }    
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

#Required Parameters
$sSiteUrl = "http://<SiteCollectionUrl>"
$sWebAppUrl = "http://<WebAppUrl>"
$sOperationType="SC"

Get-WorkflowServiceStatus -sSiteCUrl $sSiteUrl -sWebAppUrl $sWebAppUrl -sOperationType $sOperationType

$sOperationType="WA"

Get-WorkflowServiceStatus -sSiteCUrl $sSiteUrl -sWebAppUrl $sWebAppUrl -sOperationType $sOperationType