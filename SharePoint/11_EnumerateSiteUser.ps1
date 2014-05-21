param ([boolean] $writeToFile = $true)
if($writeToFile -eq $true)
{
    $outputPath = Read-Host "Outputpath (e.g. C:\directory\filename.txt)"
}

 [System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.SharePoint”) > $null
 function EnumerateUserRolesPermissions ([string]$webURL)
 {
    $site = new-object Microsoft.SharePoint.SPSite($webURL)
    $web = $site.OpenWeb()
    $webUsers = $web.Users
    $groups = $web.sitegroups
    foreach($webUser in $webUsers)
    {
        $Permissions = $web.Permissions
        foreach($group in $groups)
        {
            foreach($Permission in $Permissions)
            {
                if($webUser.ID -eq $Permission.Member.ID)
                {
                    foreach ($role in $webUser.Roles)
                    {
                        if ($role.Type -ne [Microsoft.SharePoint.SPRoleType]::None)
                        {
                            write-host $webURL,“;“,$webUser.LoginName,“;“,$webUser.Name,“;",$role.Type.ToString(),";",$webUser.groups
                            Add-Content -Path $outputPath -Value $webURL,“;“,$webUser.LoginName,“;“,$webUser.Name,“;",$role.Type.ToString(),";",$webUser.groups
                            Add-Content -Path $outputPath -Value "`n"
                        }
                    }
                }
            if($group.ID -eq $Permission.Member.ID)
            {
                foreach ($role in $group.Roles)
                {
                    if ($role.Type -ne [Microsoft.SharePoint.SPRoleType]::None)
                    {
                        foreach($user in $group.users)
                        {
                            write-host $webURL,“;“,$user.LoginName,“;“,$user.Name,“;",$role.Type.ToString(),";",$group.name
                            Add-Content -Path $outputPath -Valu $webURL,“;“,$user.LoginName,“;“,$user.Name,“;",$role.Type.ToString(),";",$group.name
                            Add-Content -Path $outputPath -Value "`n"
                        }
                    }
                }
            }
        }
     }
    }
 }

 function EnumerateSiteUsers()
 {
     [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
     $farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
     foreach ($spService in $farm.Services) 
     {
        if (!($spService -is [Microsoft.SharePoint.Administration.SPWebService])) {
            continue;
        }
        foreach ($webApp in $spService.WebApplications)
        {
            if ($webApp -is [Microsoft.SharePoint.Administration.SPAdministrationWebApplication])
                { continue }
            $webAppUrl = $webApp.GetResponseUri('Default').AbsoluteUri
            foreach ($site in $webApp.Sites)
            {
                foreach ($web in $site.AllWebs)
                {
                    EnumerateUserRolesPermissions $web.url
                }
            }
        }
    }
 }
 
 EnumerateSiteUsers > UsersInventory.txt