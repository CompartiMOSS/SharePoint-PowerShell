# This utility updates user Emails in SharePoint from their email in Active Directory
# Not needed for SharePoint with the user profile service running
#
# To Report on out of date  user emails
#  .\FixUserEmails.ps1 http://sharepointurl
# To update emails 
#  .\FixUserEmails.ps1 http://sharepointurl $true
param($WebApplication,$fix)

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") 

function GetUsersEmailFromAD($DirectoryRoot,  $SamAccountName) {

 $searcher = new-object System.DirectoryServices.DirectorySearcher($DirectoryRoot);
 $searcher.Filter = [string]::format("(sAMAccountName={0})" , $sAMAccountName)

 [void]$searcher.PropertiesToLoad.Add("cn");  
 [void]$searcher.PropertiesToLoad.Add("mail");  # e-mail address 
 
 $result = $searcher.FindAll();
 
 if ($result.Count -eq 0) { write-host "User Not found"; return $null }
 if ($result.Count -gt 1) { write-host "Too many users found";return $null }
 
 $propvalue=$result[0].Properties["mail"]
 
 if ($propvalue -eq $null -or  $propvalue.Count -eq 0 ) {write-host "User's email not set"; return "" }
 
 return $propvalue[0].ToString();
 
 $result.Dispose()
 
}


function GetUsersEmail($DirectoryRoot,  $SamAccountName) {

if ($script:UserLookup -eq $null) { $script:UserLookup=@{} }

if ($script:UserLookup.ContainsKey($SamAccountName)) {

	return $script:UserLookup[$SamAccountName]

} else {
	
	$email= GetUsersEmailFromAD $DirectoryRoot $SamAccountName
	
	if ($email -ne $null) {
		$script:UserLookup[$SamAccountName]=$email			
	} else {
		write-host "email is null"
	}

	return $email

}

}


$WebApp=[Microsoft.SharePoint.Administration.SPWebApplication]::Lookup($WebApplication)

foreach ($site in $webapp.sites) {
echo "$($site.Url)"

	foreach($web in $site.Allwebs) {
	
	echo "  $($web.ServerRelativeUrl)"	
		foreach($user in $web.AllUsers) {
		 # skip groups, system user and for 2010 FBA claims users
			$bIsFBA=$user.LoginName.StartsWith("i:0#.f")
		 
		 if ($user.IsDomainGroup -eq $false -and $user.Name -ne "System Account" -and $user.Name -ne "NT AUTHORITY\LOCAL SERVICE" -and $bIsFBA -eq $false) {
			$samAccountName=$user.LoginName
			if ($samAccountName.IndexOf("\") -gt 0) { $samAccountName= $samAccountName.substring($samAccountName.IndexOf("\")+1)  }
			echo "`t$($user.Name)-$($user.Email)-$samAccountName"	
			$email=GetUsersEmail $DirectoryRoot $samAccountName
			if ($email -eq $null -or $email.Length -eq 0 ) { write-host "User has no email set in AD" }
			else {
				if ($user.Email -ne $email) { 
					write-host "`t`tEmail is different: Old ($($user.Email)) New ($email)"
					if ($fix) {
						write-host "Updating from $($user.Email) to $email"
						$user.Email=$email
						$user.Update()
					}
				}
			}
		}
		}
	
	$web.Dispose()
	}

$site.Dispose()
}

 