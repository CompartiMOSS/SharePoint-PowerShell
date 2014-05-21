############################################################################
#
#	Script:				Get-FeatureWebpartInventory.ps1
#	Author:				Sean Kelley 
#	Create Date: 		10/5/2010
#	Version:			1.0
#	Requirements:		PowerShell 2.0 and MOSS 2007 or 2010
#
#	Details:			This tool is used to export SharePoint 2007 farm features and webparts. It is done by using a combination of
#						stsadm -o enumallwebs -includefeatures -includewebparts and also some custom code to get site, webapp and farm scoped features
#						The output is a CSV file which can be opened and Excel and used to analyze the usage of customizations across your SharePoint environment
#	Disclaimer:
#
#	The sample script and data file described in this guide are not supported 
#	under any Microsoft standard support program or service. The sample script 
#	and data file are provided AS IS without warranty of any kind. 
#	Microsoft further disclaims all implied warranties including, without limitation, 
#	any implied warranties of merchantability or of fitness for a particular purpose. 
#	The entire risk arising out of the use or performance of the sample scripts and 
#	documentation remains with you. In no event shall Microsoft, its authors, 
#	or anyone else involved in the creation, production, or delivery of the scripts 
#	be liable for any damages whatsoever (including, without limitation, damages 
#	for loss of business profits, business interruption, loss of business information, 
#	or other pecuniary loss) arising out of the use of or inability to use the sample 
#	scripts or documentation, even if Microsoft has been advised of the possibility 
#	of such damages.
#

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Administration")

#allows appending to a CSV file. original source: http://poshcode.org/1590 
function Export-CSV {
[CmdletBinding(DefaultParameterSetName='Delimiter',
  SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
 [Parameter(Mandatory=$true, ValueFromPipeline=$true,
           ValueFromPipelineByPropertyName=$true)]
 [System.Management.Automation.PSObject]
 ${InputObject},

 [Parameter(Mandatory=$true, Position=0)]
 [Alias('PSPath')]
 [System.String]
 ${Path},
 
 #region -Append (added by Dmitry Sotnikov)
 [Switch]
 ${Append},
 #endregion 

 [Switch]
 ${Force},

 [Switch]
 ${NoClobber},

 [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
 [System.String]
 ${Encoding},

 [Parameter(ParameterSetName='Delimiter', Position=1)]
 [ValidateNotNull()]
 [System.Char]
 ${Delimiter},

 [Parameter(ParameterSetName='UseCulture')]
 [Switch]
 ${UseCulture},

 [Alias('NTI')]
 [Switch]
 ${NoTypeInformation})

begin
{
 # This variable will tell us whether we actually need to append
 # to existing file
 $AppendMode = $false
 
 try {
  $outBuffer = $null
  if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
  {
      $PSBoundParameters['OutBuffer'] = 1
  }
  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Export-Csv',
    [System.Management.Automation.CommandTypes]::Cmdlet)
        
        
	#String variable to become the target command line
	$scriptCmdPipeline = ''

	# Add new parameter handling
	#region Dmitry: Process and remove the Append parameter if it is present
	if ($Append) {
  
		$PSBoundParameters.Remove('Append') | Out-Null
    
  if ($Path) {
   if (Test-Path $Path) {        
    # Need to construct new command line
    $AppendMode = $true
    
    if ($Encoding.Length -eq 0) {
     # ASCII is default encoding for Export-CSV
     $Encoding = 'ASCII'
    }
    
    # For Append we use ConvertTo-CSV instead of Export
    $scriptCmdPipeline += 'ConvertTo-Csv -NoTypeInformation '
    
    # Inherit other CSV convertion parameters
    if ( $UseCulture ) {
     $scriptCmdPipeline += ' -UseCulture '
    }
    if ( $Delimiter ) {
     $scriptCmdPipeline += " -Delimiter '$Delimiter' "
    } 
    
    # Skip the first line (the one with the property names) 
    $scriptCmdPipeline += ' | Foreach-Object {$start=$true}'
    $scriptCmdPipeline += '{if ($start) {$start=$false} else {$_}} '
    
    # Add file output
    $scriptCmdPipeline += " | Out-File -FilePath '$Path' -Encoding '$Encoding' -Append "
    
    if ($Force) {
     $scriptCmdPipeline += ' -Force'
    }

    if ($NoClobber) {
     $scriptCmdPipeline += ' -NoClobber'
    }   
   }
  }
 } 
  

  
 $scriptCmd = {& $wrappedCmd @PSBoundParameters }
 
 if ( $AppendMode ) {
  # redefine command line
  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      $scriptCmdPipeline
    )
 } else {
  # execute Export-CSV as we got it because
  # either -Append is missing or file does not exist
  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      [string]$scriptCmd
    )
 }

 # standard pipeline initialization
 $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
 $steppablePipeline.Begin($PSCmdlet)
 
 } catch {
   throw
 }
    
}

process
{
  try {
      $steppablePipeline.Process($_)
  } catch {
      throw
  }
}

end
{
  try {
      $steppablePipeline.End()
  } catch {
      throw
  }
}
<#

.ForwardHelpTargetName Export-Csv
.ForwardHelpCategory Cmdlet

#>

}

function parse-enumallwebstofile($xmlfile)
{			
	[xml]$enum_webs = get-content $xmlfile

	$webparts = @()
	$features = @()

	foreach($database in $enum_webs.Databases.Database)
	{
		$database 
		foreach($site in $database.Site)
		{
			#$site
			
			$siteguid = [Guid]$site.Id
			$siteobject = new-object Microsoft.SharePoint.SPSite($siteguid)
			
			
			foreach($web in $site.Webs.Web)
			{
				#$web
				#reset these to free up memory
				$webparts = @()
				$features = @()
				$siteurl = ""
				
				#determine the url of this... enumallwebs doesnt include urls and just guids and realtive urls
				if($siteobject.ServerRelativeUrl -eq $web.Url)	#its the root web
				{
					$siteurl = $siteobject.Url
				}
				else
				{
					$weburl = $web.Url
					$weburl = $weburl.Replace($siteobject.ServerRelativeUrl, "")
					
					$siteurl = $siteobject.Url + $weburl
				}
				
				foreach($webpart in $web.WebParts.WebPart)	
				{
					$row = new-object PSObject
										
					add-member -inputObject $row -memberType NoteProperty -name Database -value $database.Name		
					add-member -inputObject $row -memberType NoteProperty -name SiteId -value $site.Id
					add-member -inputObject $row -memberType NoteProperty -name WebId -value $web.Id
					add-member -inputObject $row -memberType NoteProperty -name Url -value $siteurl
					add-member -inputObject $row -memberType NoteProperty -name WebpartType -value $webpart.Type
					add-member -inputObject $row -memberType NoteProperty -name WebpartAssembly -value $webpart.Assembly
					add-member -inputObject $row -memberType NoteProperty -name WebpartId -value $webpart.Id
					add-member -inputObject $row -memberType NoteProperty -name Status -value $webpart.Status
					add-member -inputObject $row -memberType NoteProperty -name Count -value $webpart.Count
					
					$webparts += $row

				}
				
				foreach($feature in $web.Features.Feature)
				{
					$row = new-object PSObject
		
					#write-host $database.Name $site.Id $web.Id $web.Url $webpart.Id $webpart.Status $webpart.Count 
					
					add-member -inputObject $row -memberType NoteProperty -name Database -value $database.Name		
					add-member -inputObject $row -memberType NoteProperty -name SiteId -value $site.Id
					add-member -inputObject $row -memberType NoteProperty -name WebId -value $web.Id
					add-member -inputObject $row -memberType NoteProperty -name Url -value $siteurl
					add-member -inputObject $row -memberType NoteProperty -name FeatureId -value $feature.Id
					add-member -inputObject $row -memberType NoteProperty -name FeatureDisplayName -value $feature.DisplayName
					add-member -inputObject $row -memberType NoteProperty -name FeatureInstallPath -value $feature.InstallPath
					add-member -inputObject $row -memberType NoteProperty -name FeatureScope -value "Web"	#these are always going to be web scoped features but enumallwebs doesnt give us scope
					add-member -inputObject $row -memberType NoteProperty -name Status -value $feature.Status
					
					$features += $row
				}
				
				#append to the exsiting output (helps with scaling)
				$webparts | Export-Csv -NoTypeInformation -Append $script:outputreport_webparts
				$features | Export-Csv -NoTypeInformation -Append $script:outputreport_features
			}
		}
	}
}

function create-sitecollectionfeaturesxml()
{
	$scfeatures = @()
	$script:webid = "00000000-0000-0000-0000-000000000000" #since these features are scoped for sc, the webid is always 00000 etc

	#first we'll get the definitions of features
	#looks like sharepoint is actually querying the file system for the name of the folder that has the feature
	#the DB does not have feature names, only an object and a path to the feature.xml for a given feature
	$farm = [Microsoft.SharePoint.Administration.SPFarm]::get_Local()
	$spfeaturecollection = $farm.FeatureDefinitions;

	$WebService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService

	foreach($WebApplication in $WebService.WebApplications)
	{
		#these objects are not CLS compliant so we need to use some reflection to get at properties
		$DBName = [Microsoft.SharePoint.Administration.SPContentDatabase].GetProperty("Name")
		$DBCurrentSiteCount = [Microsoft.SharePoint.Administration.SPContentDatabase].GetProperty("CurrentSiteCount")
		$DBCurrentSites = [Microsoft.SharePoint.Administration.SPContentDatabase].GetProperty("Sites")
			
		$ContentDBCollection = $WebApplication.ContentDatabases
		foreach($ContentDB in $ContentDBCollection)
		{
			$CurrentDBName = $DBName.GetValue($ContentDB, $null)
			$CurrentDBCurrentSiteCount = $DBCurrentSiteCount.GetValue($ContentDB, $null)
			$CurrentDBCurrentSites = $DBCurrentSites.GetValue($ContentDB, $null)
			
			foreach($site in $CurrentDBCurrentSites)
			{				
				$scfeatures = @()	#reset for each site
				Write-Host $site.Url
				foreach($feature in $site.Features)
				{
					$row = new-object PSObject
					
					#write-host $database.Name $site.Id $web.Id $web.Url $webpart.Id $webpart.Status $webpart.Count 
										
					add-member -inputObject $row -memberType NoteProperty -name Database -value $CurrentDBName	
					add-member -inputObject $row -memberType NoteProperty -name SiteId -value $site.Id
					add-member -inputObject $row -memberType NoteProperty -name WebId -value $script:webid
					add-member -inputObject $row -memberType NoteProperty -name Url -value $site.Url
					add-member -inputObject $row -memberType NoteProperty -name FeatureId -value $($feature.DefinitionId)
					add-member -inputObject $row -memberType NoteProperty -name FeatureDisplayName -value $($spfeaturecollection[$feature.DefinitionId].DisplayName)
					add-member -inputObject $row -memberType NoteProperty -name FeatureInstallPath -value $($spfeaturecollection[$feature.DefinitionId].RootDirectory)
					add-member -inputObject $row -memberType NoteProperty -name FeatureScope -value $($spfeaturecollection[$feature.DefinitionId].Scope)
					add-member -inputObject $row -memberType NoteProperty -name Status -value $($spfeaturecollection[$feature.DefinitionId].Status)					
					
					$scfeatures += $row
				}
				
				#append to the exsiting output (helps with scaling)
				$scfeatures | Export-Csv -NoTypeInformation -Append $script:outputreport_features
			}
		}
	}

	
}

function create-farmandwebappfeaturesxml()
{
	$farm = [Microsoft.SharePoint.Administration.SPFarm]::get_Local()
	$spfeaturecollection = $farm.FeatureDefinitions;

	$WebService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService

	$farmlevelfeatures = $WebService.Features
	$farmfeatureoutput = @()	#reset for each webapp
	
	#get farm scoped features
	foreach($farmlevelfeature in $farmlevelfeatures)
	{
		$farmfeature = $farmlevelfeature.Definition	
		#Write-Host $farmfeature.Id $farmfeature.DisplayName $farmfeature.RootDirectory $farmfeature.Scope $farmfeature.Status
		
		$row = new-object PSObject
		
		add-member -inputObject $row -memberType NoteProperty -name Database -value "N/A"	
		add-member -inputObject $row -memberType NoteProperty -name SiteId -value "N/A"	
		add-member -inputObject $row -memberType NoteProperty -name WebId -value "N/A"	
		add-member -inputObject $row -memberType NoteProperty -name Url -value $farmfeature.Farm
		add-member -inputObject $row -memberType NoteProperty -name FeatureId -value $farmfeature.Id
		add-member -inputObject $row -memberType NoteProperty -name FeatureDisplayName -value $farmfeature.DisplayName
		add-member -inputObject $row -memberType NoteProperty -name FeatureInstallPath -value $farmfeature.RootDirectory
		add-member -inputObject $row -memberType NoteProperty -name FeatureScope -value $farmfeature.Scope
		add-member -inputObject $row -memberType NoteProperty -name Status -value $farmfeature.Status
		$farmfeatureoutput += $row
	}

	#append to the exsiting output (helps with scaling)
	$farmfeatureoutput | Export-Csv -NoTypeInformation -Append $script:outputreport_features
	
	Write-Host "`nFound $($farmFeatureoutput.Count) farm scoped features."
	
	#now get webapp scoped features
	foreach($WebApplication in $WebService.WebApplications)
	{
		$webappfeatures = @()	#reset for each webapp
	
		$default_spurlzone = [Microsoft.SharePoint.Administration.SPUrlZone]::Default
		$webappurl = $WebApplication.GetResponseUri($default_spurlzone).AbsoluteUri
		
	
		foreach($webappfeature in $WebApplication.Features)
		{
			$webappfeaturedef = $webappfeature.Definition
			#Write-Host $webappfeaturedef.Id $webappfeaturedef.DisplayName $webappfeaturedef.RootDirectory $webappfeaturedef.Scope $webappfeaturedef.Status

			$row = new-object PSObject
			
			#write-host $database.Name $site.Id $web.Id $web.Url $webpart.Id $webpart.Status $webpart.Count 
	
			add-member -inputObject $row -memberType NoteProperty -name Database -value "N/A"	
			add-member -inputObject $row -memberType NoteProperty -name SiteId -value "N/A"	
			add-member -inputObject $row -memberType NoteProperty -name WebId -value "N/A"	
			add-member -inputObject $row -memberType NoteProperty -name Url -value $webappurl
			add-member -inputObject $row -memberType NoteProperty -name FeatureId -value $webappfeaturedef.Id
			add-member -inputObject $row -memberType NoteProperty -name FeatureDisplayName -value $webappfeaturedef.DisplayName
			add-member -inputObject $row -memberType NoteProperty -name FeatureInstallPath -value $webappfeaturedef.RootDirectory
			add-member -inputObject $row -memberType NoteProperty -name FeatureScope -value $webappfeaturedef.Scope
			add-member -inputObject $row -memberType NoteProperty -name Status -value $webappfeaturedef.Status
			
			$webappfeatures += $row
		}
		
		#append to the exsiting output (helps with scaling)
		$webappfeatures | Export-Csv -NoTypeInformation -Append $script:outputreport_features
		
		Write-Host "`nFound $($webappfeatures.Count) webapp scoped features for $($webappurl)"
	}
}

#############################################

[IO.Directory]::SetCurrentDirectory((Convert-Path (Get-Location -PSProvider FileSystem)))
$current_directory = Convert-Path (Get-Location -PSProvider FileSystem)

$filedate = get-date -format "M-d-yyyy_hh-mm-ss"
$filename = "feature_report-" + $filedate + ".csv"
$filename2 = "webpart_report-" + $filedate + ".csv"

$script:outputreport_features = $current_directory + "\" + $filename
$script:outputreport_webparts = $current_directory + "\" + $filename2

$script:enumallwebsoutput = [IO.Path]::GetTempFileName()


Write-Host "`nFeature and WebPart Inventory" 
Write-Host "*******************************************`n" 
Write-Host "Feature report will be written to location: $script:outputreport_features" -ForegroundColor Green
Write-Host "Webpart report will be written to location: $script:outputreport_webparts" -ForegroundColor Green
Write-Host ""
Write-Host "Running stsadm command stsadm.exe -o enumallwebs -includefeatures -includewebparts" -ForegroundColor DarkGreen
Write-Host "Note this can take hours depending on the size of the farm." -ForegroundColor DarkGreen

#sharepoint version detection
if(Test-Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\12\BIN\stsadm.exe")
{
	Write-Host "Detected SharePoint 2007 farm." -ForegroundColor Green 
	& 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\12\BIN\stsadm.exe' -o enumallwebs -includefeatures -includewebparts | out-file $($script:enumallwebsoutput)
}
elseif(Test-Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\BIN\stsadm.exe")
{
	Write-Host "Detected SharePoint 2010 farm." -ForegroundColor Green 
	& 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\BIN\stsadm.exe' -o enumallwebs -includefeatures -includewebparts | out-file $($script:enumallwebsoutput)
}
else
{
	Write-Host "Can't find a SharePoint bin folder. Are you running this on a SharePoint WFE? Exiting." -ForegroundColor Red
	exit
}

#run enumallwebs -includefeatures -includeswebparts and parse output to csv
parse-enumallwebstofile $script:enumallwebsoutput

Write-Host ""
Write-Host "`nFinished running and exporting enumallwebs. Generatating report for site collection scoped features." -ForegroundColor DarkGreen

#run custom function to collect site collection scoped features and parse output to csv
create-sitecollectionfeaturesxml 

Write-Host "`nFinished running and exporting SC feature collection. Generatating report for webapp and farm level features." -ForegroundColor DarkGreen

#run custom code to collect webapp and farm level scoped features
create-farmandwebappfeaturesxml

Write-Host "`nFinished running and exporting webapp & farm scoped features. " -ForegroundColor DarkGreen

Write-Host "Feature Inventory Report located at: `n $script:outputreport_features" -ForegroundColor Green
Write-Host "Webpart Inventory Report located at: `n $script:outputreport_webparts" -ForegroundColor Green

$answer = Read-Host "Do you want to open the reports? Y or N"

if($answer -eq "Y")
{
	& "$($script:outputreport_features)"
	& "$($script:outputreport_webparts)"
}



