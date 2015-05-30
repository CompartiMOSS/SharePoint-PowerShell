############################################################################################################################################
# Script that allows to get all the App Security Principals for an Office 365 tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sMessage: Message to be shown when prompting for user credentials.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to get all the App Security Principals for an Office 365 tenant
function Get-SPOAppPrincipals
{
    param ($sUserName,$sPassword,$sMessage)
    try
    {    
        $msolcred = Get-Credential -UserName $sUserName -Message $sMessage
        Connect-MsolService -Credential $msolcred
        Get-MsolServicePrincipal | Select DisplayName,AppPrincipalId,AccountEnabled | Format-Table   
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your O365 Credentials"
Get-SPOAppPrincipals -sSPOSiteUrl $sSPOSiteCollection -sUserName $sUserName -sMessage $sMessage

