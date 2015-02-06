############################################################################################################################################
#Script that allows to add Users to a SPO Group in different site collections / sites reading the information from a CSV file
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: SharePoint Online Site.
#  -> $sGroup: SPO Group where users are going to be added.
#  -> $sUserToAdd: User to be added.
#  -> $sInputFile: CSV file with the required information.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a SharePoint Group in a SharePoint Online Site
function Add-SPOUsersToGroup
{
    param ($sSiteColUrl,$sUserName,$sPassword,$sGroup,$sUserToAdd)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding User $sUserToAdd to group $sGroup in $sSiteColUrl" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green     

        #SPO Client Object Model Context        
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteColUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 
        
        #Getting the SharePoint Groups for the site                        
        $spoGroups=$spoCtx.Web.SiteGroups
        $spoCtx.Load($spoGroups)        
        #Getting the specific SharePoint Group where we want to add the user
        $spoGroup=$spoGroups.GetByName($sGroup);
        $spoCtx.Load($spoGroup)       
        #Ensuring the user we want to add exists
        $spoUser = $spoCtx.Web.EnsureUser($sUserToAdd)
        $spoCtx.Load($spoUser)
        $spoUserToAdd=$spoGroup.Users.AddUser($spoUser)
        $spoCtx.Load($spoUserToAdd)
        $spoCtx.ExecuteQuery()  
                
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "SharePoint User $sUserToAdd added succesfully!!" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Function that allows to add users to SharePoint Groups in different Site Collections.
#The information about the Site Collection, SharePoint Group and User to be added is read from a CSV file
function Add-SPOUsersToGroupFromCSV
{
    param ($sInputFile,$sUserName,$sPassword)
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

        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"
    
        # Adding Users To Groups
        foreach ($user in $tblUsers) 
        { 
            Add-SPOUsersToGroup -sSiteColUrl $user.SPOSCollection -sUsername $sUserName -sPassword $sPassword -sGroup $user.SPOGroup -sUserToAdd $user.SPOUser
        } 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    } 
}
 
$sUserName = "<SPOAdminUser>@<Office365Domain>.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<Office365Password>" -asplaintext -force
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\<CSVFileName>.csv"

Add-SPOUsersToGroupFromCSV -sInputFile $sInputFile -sUserName $sUserName -sPassword $sPassword