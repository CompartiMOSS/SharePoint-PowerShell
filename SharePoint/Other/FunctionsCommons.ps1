Function WriteInfo($msg, $nonewline, $nodate)
{
	if($nodate -ne $true) {
		$newdate = (Get-Date).ToString() + " -"
	}
	if($nonewline -eq $true) {
		Write-Host -NoNewline $newdate $msg  -foregroundColor Green    
	} else {
		Write-Host $newdate $msg  -foregroundColor Green
	} 
}
Function WriteWarning($msg)
{
	Write-Host (Get-Date).ToString() - $msg  -foregroundColor Yellow    
}
Function WriteError($msg)
{
	Write-Host (Get-Date).ToString() - $msg  -foregroundColor Red    
}

Function LoadSharePointPowerShell()
{
	$snapin = Get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
	if ($snapin -eq $null) {		
		WriteInfo "Cargando PowerShell de SharePoint..."
		Add-PSSnapin "Microsoft.SharePoint.Powershell"
		[system.reflection.assembly]::LoadWithPartialName("Microsoft.Sharepoint")
		WriteInfo "PowerShell de SharePoint cargado."
		$host.Runspace.ThreadOptions = "ReuseThread"
	}
}

Function EnsureRunAsAdministrator($definition) {
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   #$Host.UI.RawUI.WindowTitle = $definition + "(Elevated)"
   #$Host.UI.RawUI.BackgroundColor = "DarkBlue"
   #clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   #WriteInfo "myInvocation.MyCommand.Definition: '$definition'"
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = "-NoExit $definition";
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   #WaitForKeyPressed

   # Exit from the current, unelevated, process
   exit


   }
}

Function GetAdminCredentials()
{
	WriteInfo "Obteniendo credenciales de administración..."
	$adminCredentials = Get-Credential
	return $adminCredentials
}

Function GetManagedAccount($adminCredentials)
{
	WriteInfo "Obteniendo cuenta manejada..."
	$managedAccount = Get-SPManagedAccount $adminCredentials.UserName -ErrorAction SilentlyContinue
	if(!$managedAccount)
	{
		$managedAccount = New-SPManagedAccount -Credential $adminCredentials
	}
	return $managedAccount
}

Function SolutionExists([string]$WSPName)
{
	
	WriteInfo "Comprobando si la solución '$WSPName' está previamente desplegada..."
	$solution = Get-SPSolution -Identity $WSPName -EA 0
			
	return ($solution -ne $null)
}
	
Function WaitForDeploymentJob([string]$SolutionFileName)
{ 
	$JobName = "*solution-deployment*$SolutionFileName*"
	WaitForJob $JobName
}

Function WaitForJob([string]$JobName)
{ 
	$job = Get-SPTimerJob | ?{ $_.Name -like $JobName }
	if ($job -eq $null) 
	{
		WriteWarning 'Timer job no encontrado.'
	}
	else
	{
		$JobFullName = $job.Name
		WriteInfo "Esperando a que termine el job '$JobFullName'..."
		
		while ((Get-SPTimerJob $JobFullName) -ne $null) 
		{
			Write-Host -NoNewLine .
			Start-Sleep -Seconds 2
		}
		Write-Host .
		WriteInfo "Job terminado."
	}
}

Function UninstallPackage([string]$WebApplication, [string] $WSPName, $WebScope)
{
	$SolutionDeployed = SolutionExists $WSPName
	if($SolutionDeployed){
		WriteInfo "Desinstalando la solución '$WSPName'..."
		$SolutionId=Get-SPSolution -Identity $WSPName	
		if($WebScope)
		{
			Uninstall-SPSolution -Identity $SolutionId.SolutionId -confirm:$false -WebApplication $WebApplication
		}
		else
		{
			Uninstall-SPSolution -Identity $SolutionId.SolutionId -confirm:$false
		}
		WaitForDeploymentJob($WSPName)
		WriteInfo "Eliminando la solución '$WSPName'..."
		Remove-SPSolution –Identity $SolutionId.SolutionId -Force -confirm:$false
	}
}

Function DeployPackage([string]$WebApplication, [string] $WSPName, $WebScope)
{	
	WriteInfo "Instalando el paquete '$WSPName'..."
	$SolutionPath=$PSScriptRoot + "\" + $WSPName 
	UninstallPackage $WebApplication $WSPName $WebScope
	
	WriteInfo "Añadiendo solución..."
	Add-SPSolution $SolutionPath	
	WriteInfo "Instalando solución..."
	if($WebScope)
	{
		Install-SPSolution –Identity $WSPName -Force -WebApplication $WebApplication -GACDeployment
	}
	else
	{
		Install-SPSolution –Identity $WSPName -Force -GACDeployment
	}
	WaitForDeploymentJob $WSPName
	WriteInfo "Solución instalada."	
}

Function SetCustomMasterPage([string]$WebUrl, [string]$MasterPageUrl)
{
	WriteInfo "Configurando custom masterpage en '$WebUrl'..."
	$Web = Get-SPWeb -Identity $WebUrl
	$Web.CustomMasterUrl=$MasterPageUrl
	$Web.Update()
}



#Agregamos valores de configuración
Function SetValue($list, [string]$key, [string]$value)
{
	$items = $null
	if($list.Items.Count -gt 0) {
		$spquery = new-object Microsoft.SharePoint.SPQuery
		$query = "<Where><Eq><FieldRef Name=""Title""></FieldRef><Value Type=""Text"">$key</Value></Eq></Where>" 
		$spquery.Query = $query
		$items = $list.GetItems($spquery)
	}
	if($items.Count -eq 0) {
		WriteInfo "Agregando valor $($key): '$($value)'..."
		$item = $list.Items.Add() #No existe -> agregamos elemento
	} else {
		WriteInfo "Editando valor $($key): '$($value)'..."
		$item = $items[0] #Existe -> actualizamos
	}
	$item["Title"] = $key
	$item["Value"] = $value
	$item.update()
	$list.update()
}

Function BackupSolution($solutionName, $fileName) {
	$solution = get-spsolution $solutionName
	if($solution) {
		WriteInfo "Haciendo backup de la solución '$solutionName' en '$fileName'..." $true
		try { 
			$solution.SolutionFile.SaveAs("$filename") 
			WriteInfo " Hecho." $false $true
		} 
		catch 
		{ 
			WriteError " Error: $_" $false $true
		} 
		WriteInfo "Backup de la solución '$solutionName' finalizado."
	} else {
		WriteWarning "La solución '$solutionName' no está instalada."
	}
}


#Funciones para trabajar con campos y listas
Function AddField($list, $fieldName, $fieldType){
	try { 
		$field = $list.Fields.GetFieldByInternalName($fieldName)
		WriteWarning "El campo '$fieldName' ya existe en la lista '$list'."
	} catch { 
		#Error: no existe -> lo creamos
		$list.Fields.Add($fieldName, $fieldType, $false)
		WriteInfo "Campo '$fieldName' agregado a la lista '$list'."
	} 
}

Function AddLookupField($list, $fieldName, $lookupList, $lookupFieldName){
	try { 
		$field = $list.Fields.GetFieldByInternalName($fieldName)
		WriteWarning "El campo '$fieldName' ya existe en la lista '$list'."
	} catch { 
		#Error: no existe -> lo creamos
		$strPrimaryCol = $list.Fields.AddLookup($fieldName, $lookupList.Id, $false)
		$primaryCol = [Microsoft.SharePoint.SPFieldLookup]$list.Fields.GetFieldByInternalName($strPrimaryCol)
		$primaryCol.LookupField = $lookupFieldName
		$primaryCol.Update()
		WriteInfo "Campo '$fieldName' agregado a la lista '$list'."
	}
}

Function AddDependentLookupField($list, $fieldName, $lookupId, $lookupFieldName){
	 try { 
		$field = $list.Fields.GetFieldByInternalName($fieldName)
		WriteWarning "El campo '$fieldName' ya existe en la lista '$list'."
	} catch { 
		#Error: no existe -> lo creamos
		$strCol = $list.Fields.AddDependentLookup($fieldName, $lookupId)
		$Col = [Microsoft.SharePoint.SPFieldLookup]$list.Fields.GetFieldByInternalName($strCol)
		$Col.LookupField = $lookupFieldName 
		$Col.Update()
		WriteInfo "Campo '$fieldName' agregado a la lista '$list'."
	}
}

Function AddChoices($list, $fieldName, $values){
	$field = $list.Fields.GetFieldByInternalName($fieldName)
	foreach($value in $values) {
		if($field.Choices.Contains([string]$value)) {
			WriteWarning "El campo '$fieldName' de la lista '$list' ya contiene el valor '$value'."
		} else {
			WriteInfo "Agregando valor '$value' a la lista '$list'."
			$field.Choices.Add($value)
			$field.update()
		}
	}
}

Function AddChoice($list, $fieldName, $value){
	$field = $list.Fields.GetFieldByInternalName($fieldName)
	if($field.Choices.Contains($value)) {
		WriteWarning "El campo '$fieldName' de la lista '$list' ya contiene el valor '$value'."
	} else {
		WriteInfo "Agregando valor '$value' a la lista '$list'."
		$field.Choices.Add($value)
		$field.update()
	}
}

Function CopyListFiles($list) {
	$folder = $list.RootFolder
	$path = "$PSScriptRoot\Site\Lists\$($list.Title)"
	WriteInfo "Copiando archivos desde '$path' a la lista '$folder'..." 
	$files = ([System.IO.DirectoryInfo] (Get-Item $path)).GetFiles()
	ForEach($file in $files)
	{
		#Open file
		$fileStream = ([System.IO.FileInfo] (Get-Item $file.FullName)).OpenRead()
		#Add file
		WriteInfo "Copiando archivo '$($file.Name)' a '$($folder.ServerRelativeUrl)'..." $true
		$spFile = $folder.Files.Add($file.Name, [System.IO.Stream]$fileStream, $true)
		WriteInfo "Success" $false $true
		#Close file stream
		$fileStream.Close();
	}
}

Function RenameField($list, $internalName, $newName) {
	$field = $list.Fields.GetFieldByInternalName($internalName)
	$field.Title = $newName
	$field.Update() 
}