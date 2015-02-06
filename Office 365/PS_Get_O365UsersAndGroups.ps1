############################################################################################################################################
# Script that gets all the Groups on an Office 365 tenant and for each Group it also gets the users member of it.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sInputFile: Message to show in the user credentials prompt.
############################################################################################################################################
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add to Office 365 the list of users contained in the CSV file.
function Get-UsersAndGroupsOffice365
{    
    try
    {   
        Write-Host "Getting Office 365 Groups and Users ..." -foregroundcolor Green    
        $gO365Groups=Get-MsolGroup
        #$gCompartiMOSSGroup=Get-MsolGroup | Where {$_.DisplayName -eq "CompartiMOSS"}
        #
        foreach ($gO365Group in $gO365Groups) 
        { 
            Get-MsolGroupMember -GroupObjectId $gO365Group.ObjectId | Format-Table $gO365Group.DisplayName,DisplayName,EmailAddress
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    } 
}

#Connection to Office 365
$sUserName="<Office365_User>"
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365
$msolcred = get-credential -UserName $sUserName -Message $sMessage
connect-msolservice -credential $msolcred
Get-UsersAndGroupsOffice365