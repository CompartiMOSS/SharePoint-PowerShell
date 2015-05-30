############################################################################################################################################
# Script that allows to do work with Office 365 Groups using standard cmdlets for Groups
# Required Parameters: N/A
############################################################################################################################################

#Connection to Office 365
$msolCred = Get-Credential
Connect-MsolService -Credential $msolCred

#Definition of the function tthat allows to do work with Office 365 Groups using standard cmdlets for Groups
function WorkWith-Office365Groups
{
    param ($sOperationType,$sGroupName,$sNewGroupName)       
    try
    {
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Get all the Office 365 Groups in a tenant" -ForegroundColor Green                        
            Get-UnifiedGroup
            } 
        "Create" {
            Write-Host "Creating a new Office 365 Group" -ForegroundColor Green                 
            New-UnifiedGroup –DisplayName $sGroupName
            }
        "Update" {
            Write-Host "Updating an Office 365 Group" -ForegroundColor Green                 
            #The change in the name can be seen in the O365 Admin Portal
            Set-UnifiedGroup -Identity $sGroupName -DisplayName $sNewGroupName
            } 
        "Remove" {
            Write-Host "Removing an Office 365 Group" -ForegroundColor Green     
            Remove-UnifiedGroup -Identity $sGroupName
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

Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
Write-Host "Working with Groups through PowerShell." -foregroundcolor Green
Write-Host "-----------------------------------------------------------"  -foregroundcolor Green

$sOperationType="Read"
$sGroupName="O365 PowerShell Group"
WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sGroupName
$sOperationType="Create"
WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sGroupName
$sOperationType="Update"
$sNewGroupName="Test PS"
WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sGroupName -sNewGroupName $sNewGroupName
$sOperationType="Remove"
$sNewGroupName="Test PS"
WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sNewGroupName
