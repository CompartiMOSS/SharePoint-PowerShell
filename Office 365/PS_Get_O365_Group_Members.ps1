############################################################################################################################################
# Script that allows to get the members for each Office 365 Group defined in an Office 365 tenant. 
# Required Parameters: N/A.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add to Office 365 the list of users contained in the CSV file.
function Get-O365Members
{
    param ($sInputFile)
    try
    {   
        #Getting all the Groups in the tenant        
        Write-Host "Getting all the members for each O365 Group in the tenant ..." -foregroundcolor Green    
        $O365Groups=Get-UnifiedGroup
        # Deleting the users
        Write-Host "Adding the Office 365 users ..." -ForegroundColor Green    
        foreach ($O365Group in $O365Groups) 
        { 
            Write-Host "Members of Group: " $O365Group.DisplayName -ForegroundColor Green
            Get-UnifiedGroupLinks –Identity $O365Group.Identity –LinkType Members
            Write-Host
        } 
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
$msolCred = Get-Credential -UserName $sUserName -Message $sMessage
Connect-MsolService -credential $msolCred

#Getting Groups Information
Get-O365Members

