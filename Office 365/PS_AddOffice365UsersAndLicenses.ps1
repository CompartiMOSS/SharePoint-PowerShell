############################################################################################################################################
# Script that allows to do a add users to Office 365 in bulk. The users are read from a CSV file. 
# The csv file only needs a column that stores the account principal name for each user to be added to Office 365
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sInputFile: Message to show in the user credentials prompt.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add to Office 365 the list of users contained in the CSV file.
function Add-Office365Users
{
    param ($sInputFile)
    try
    {   
        # Reading the Users CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblUsers = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -foregroundcolor Red
            exit 
        }         
        
        # Deleting the users
        Write-Host "Adding the Office 365 users ..." -foregroundcolor Green    
        foreach ($user in $tblUsers) 
        { 
            "Adding user " + $user.UserPrincipalName.ToString()            
            New-MsolUser -UserPrincipalName $user.UserPrincipalName -DisplayName $user.UserDisplayName
        } 

        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        Write-Host "All the users have been added. The processs is completed." -foregroundcolor Green
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    } 
}

#Definition of the function that allows to assign Office 365 licenses to the specific users read from a CSV file.
function Add-Office365LicensesToUsers
{
    param ($sInputFile,$sOperationType)
    try
    {   
        # Reading the Users CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblUsers = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -foregroundcolor Red
            exit 
        } 
        
        # Deleting the users
        $msolAccountSKU=Get-MsolAccountSku        
        Write-Host "Adding the Office 365 licenses ..." -foregroundcolor Green    
        foreach ($user in $tblUsers) 
        {    
            Write-Host "--------------------------------------------------------"
            Write-Host "Adding license $msolAccountSKU.AccountSkuId to the user " $user.UserPrincipalName.ToString()
            Write-Host "--------------------------------------------------------"    
            #Setting the location for the user
            Set-MsolUser -UserPrincipalName $user.UserPrincipalName -UsageLocation "ES"
            switch ($sOperationType) 
                { 
                "Remove" {
                    #Remove complete SKU
                    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses $msolAccountSKU.AccountSkuId
                    }
                "Add" {
                    #Add complete SKU      
                    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -AddLicenses $msolAccountSKU.AccountSkuId 
                    }
                "CustomAdd" {
                    #Custom license assignment                                    
                    $msolLicenseOptions = New-MsolLicenseOptions -AccountSkuId $msolAccountSKU.AccountSkuId -DisabledPlans $user.ServicePlan                         
                    Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -LicenseOptions $msolLicenseOptions
                    }                    
                default {
                        Write-Host "Requested Operation not valid!!" -ForegroundColor Green          
                    }
                }
            #Reading the licenses available for the user
            (Get-MsolUser -UserPrincipalName $user.UserPrincipalName).Licenses.ServiceStatus
                       
        } 

        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        Write-Host "All the licenses have been assigned. The processs is completed." -foregroundcolor Green
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    } 
}

#Connection to Office 365
$sUserName="<Your_Office365_Admin_Account>"
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365
$msolcred = get-credential -UserName $sUserName -Message $sMessage
connect-msolservice -credential $msolcred

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\PS_UsersToAddOffice365.csv"

#Adding Users
Add-Office365Users -sInputFile $sInputFile

#Adding Licenses to each user
Add-Office365LicensesToUsers -sInputFile $sInputFile -sOperationType "Remove"
Add-Office365LicensesToUsers -sInputFile $sInputFile -sOperationType "Add"
Add-Office365LicensesToUsers -sInputFile $sInputFile -sOperationType "CustomAdd"
