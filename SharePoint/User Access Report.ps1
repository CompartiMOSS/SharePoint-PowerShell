Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

Function GetUserAccessReport($WebAppURL, $SearchUser)
{
 #Get All Site Collections of the WebApp
 $SiteCollections = Get-SPSite -WebApplication $WebAppURL -Limit All

#Write CSV- TAB Separated File) Header
"URL `t Site/List `t Title `t PermissionType `t Permissions" | out-file UserAccessReport.csv

  #Check Whether the Search Users is a Farm Administrator
		$AdminWebApp= Get-SPwebapplication -includecentraladministration | where {$_.IsAdministrationWebApplication}
	  	$AdminSite = Get-SPweb($AdminWebApp.Url)
 		$AdminGroupName = $AdminSite.AssociatedOwnerGroup
  		$FarmAdminGroup = $AdminSite.SiteGroups[$AdminGroupName]

		  	foreach ($user in $FarmAdminGroup.users)
		    {
		    	if($user.LoginName -eq $SearchUser)
				{
					"$($AdminWebApp.URL) `t Farm `t $($AdminSite.Title)`t Farm Administrator `t Farm Administrator" | Out-File UserAccessReport.csv -Append
				}    		
		    }

	#Check Web Application Policies
	$WebApp= Get-SPWebApplication $WebAppURL

	foreach ($Policy in $WebApp.Policies) 
  	{
	 	#Check if the search users is member of the group
		if($Policy.UserName -eq $SearchUser)
		  	{
				#Write-Host $Policy.UserName
	 			$PolicyRoles=@()
		 		foreach($Role in $Policy.PolicyRoleBindings)
				{
					$PolicyRoles+= $Role.Name +";"
				}
				#Write-Host "Permissions: " $PolicyRoles
				
				"$($AdminWebApp.URL) `t Web Application `t $($AdminSite.Title)`t  Web Application Policy `t $($PolicyRoles)" | Out-File UserAccessReport.csv -Append
			}
 	 }
  
  #Loop through all site collections
   foreach($Site in $SiteCollections) 
    {
	  #Check Whether the Search User is a Site Collection Administrator
	  foreach($SiteCollAdmin in $Site.RootWeb.SiteAdministrators)
      	{
		  if($SiteCollAdmin.LoginName -eq $SearchUser)
			{
				"$($Site.RootWeb.Url) `t Site `t $($Site.RootWeb.Title)`t Site Collection Administrator `t Site Collection Administrator" | Out-File UserAccessReport.csv -Append
			}    		
		}
  
	   #Loop throuh all Sub Sites
       foreach($Web in $Site.AllWebs) 
       {	
			if($Web.HasUniqueRoleAssignments -eq $True)
            	{
		        #Get all the users granted permissions to the list
	            foreach($WebRoleAssignment in $Web.RoleAssignments ) 
	                { 
	                  #Is it a User Account?
						if($WebRoleAssignment.Member.userlogin)    
							{
							   #Is the current user is the user we search for?
							   if($WebRoleAssignment.Member.LoginName -eq $SearchUser)
									{
										#Write-Host  $SearchUser has direct permissions to site $Web.Url
										#Get the Permissions assigned to user
									 	$WebUserPermissions=@()
									    foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings)
									   	{
				                    	    $WebUserPermissions += $RoleDefinition.Name +";"
				                       	}
										#write-host "with these permissions: " $WebUserPermissions
										#Send the Data to Log file
										"$($Web.Url) `t Site `t $($Web.Title)`t Direct Permission `t $($WebUserPermissions)" | Out-File UserAccessReport.csv -Append
									}
							}
					#Its a SharePoint Group, So search inside the group and check if the user is member of that group
					else  
						{
                        foreach($user in $WebRoleAssignment.member.users)
                            {
							    #Check if the search users is member of the group
							 	if($user.LoginName -eq $SearchUser)
							  	{
								  	#Write-Host  "$SearchUser is Member of " $WebRoleAssignment.Member.Name "Group"
								    #Get the Group's Permissions on site
									$WebGroupPermissions=@()
							    	foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings)
							   		{
		                    	  		$WebGroupPermissions += $RoleDefinition.Name +";"
		                       		}
									#write-host "Group has these permissions: " $WebGroupPermissions
									
									#Send the Data to Log file
									"$($Web.Url) `t Site `t $($Web.Title)`t Member of $($WebRoleAssignment.Member.Name) Group `t $($WebGroupPermissions)" | Out-File UserAccessReport.csv -Append
								}
							}
						}
               	    }
				}
				
				#********  Check Lists with Unique Permissions ********/
		            foreach($List in $Web.lists)
		            {
		                if($List.HasUniqueRoleAssignments -eq $True -and ($List.Hidden -eq $false))
		                {
		                   #Get all the users granted permissions to the list
				            foreach($ListRoleAssignment in $List.RoleAssignments ) 
				                { 
				                  #Is it a User Account?
									if($ListRoleAssignment.Member.userlogin)    
										{
										   #Is the current user is the user we search for?
										   if($ListRoleAssignment.Member.LoginName -eq $SearchUser)
												{
													#Write-Host  $SearchUser has direct permissions to List ($List.ParentWeb.Url)/($List.RootFolder.Url)
													#Get the Permissions assigned to user
												 	$ListUserPermissions=@()
												    foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings)
												   	{
							                    	    $ListUserPermissions += $RoleDefinition.Name +";"
							                       	}
													#write-host "with these permissions: " $ListUserPermissions
													
													#Send the Data to Log file
													"$($List.ParentWeb.Url)/$($List.RootFolder.Url) `t List `t $($List.Title)`t Direct Permissions `t $($ListUserPermissions)" | Out-File UserAccessReport.csv -Append
												}
										}
										#Its a SharePoint Group, So search inside the group and check if the user is member of that group
									else  
										{
					                        foreach($user in $ListRoleAssignment.member.users)
					                            {
												 	if($user.LoginName -eq $SearchUser)
												  	{
													  	#Write-Host  "$SearchUser is Member of " $ListRoleAssignment.Member.Name "Group"
													    #Get the Group's Permissions on site
														$ListGroupPermissions=@()
												    	foreach ($RoleDefinition  in $ListRoleAssignment.RoleDefinitionBindings)
												   		{
							                    	  		$ListGroupPermissions += $RoleDefinition.Name +";"
							                       		}
														#write-host "Group has these permissions: " $ListGroupPermissions
														
														#Send the Data to Log file
														"$($Web.Url) `t Site `t $($List.Title)`t Member of $($ListRoleAssignment.Member.Name) Group `t $($ListGroupPermissions)" | Out-File UserAccessReport.csv -Append
													}
												}
									}	
			               	    }
				            }
		            }
				}	
			}
					
		}

#Call the function to Check User Access
GetUserAccessReport "http://SharePointWebAppURL" "Domain\LoginName"

