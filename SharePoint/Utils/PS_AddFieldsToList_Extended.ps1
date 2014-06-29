############################################################################################################################################
# This script allows to easily add new fields to an existing custom list in a SharePoint site
# Required parameters:
#   ->$sSiteUrl: Url of the site containing the list to be extended.
#   ->$sListName: Name of the list to be extended with a new field.
#   ->$sViewName: Name of the list view where we want to include the new field.
#   ->$fieldDisplayName: Display name for the field to be added.
#   ->$fieldInternalName: Internal name for the field to be added.
#   ->$sfieldType: Field type (Text, Choice, ...)
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Site Url
$sSiteUrl = "http://<SiteUrl>"

#Definition of the funcion that changes de DisplayName for an existing column
function Change-DisplayName
{
    param ($lList, $fieldDisplayName, $fieldInternalName)   
    try
    {   
        $fieldToUpdate = $lList.Fields.GetFieldByInternalName($fieldInternalName)
        if ($fieldToUpdate -ne $null) {           
            $fieldToUpdate.Title = $fieldDisplayName
            $xml = $fieldToUpdate.SchemaXml            
            if ($xml -match "\s+DisplayName\s?=\s?`"([^`"]+)`"") {
                if ($matches[1] -ne $fieldToUpdate.Title) {
                    $xml = $xml -replace $matches[0], " DisplayName=`"$($fieldToUpdate.Title)`""
                    $fieldToUpdate.SchemaXml = $xml                    
                }
            }
        }
    $fieldToUpdate.Update()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}
#Definition of the function that adds a field to an existing list
function Add-FieldToList
{
    param ($sListName, $sViewName, $fieldDisplayName, $fieldInternalName, $sfieldType)   
    try
    {
        $spSite = Get-SPSite -Identity $sSiteUrl
 	$spWeb = $spSite.OpenWeb()    
        $lList=$spWeb.Lists[$sListName] 
        # Comprobamos si la columna existe
        if($lList.Fields[$fieldDisplayName]){
            Write-host "Deleting the column in the list..."
            $lList.Fields[$fieldDisplayName].Delete();
        } 
    
        #We check the field type is not null
        if($spFieldType -ne '')
        {
            write-Host "Adding the field $fieldDisplayName in the list $sListName" -foregroundcolor blue

            #We add the field to the list
            $lList.Fields.Add($fieldInternalName,$sFieldType,$false)

            #We updte the field in the list with the Display Name
            $lList.Fields[$fieldInternalName].Title=$fieldDisplayName
            $lList.Fields[$fieldInternalName].Update()
            $lList.Update()
            #Changing the DisplayName
            Change-DisplayName -lList $lList -fieldDisplayName $fieldDisplayName -fieldInternalName $fieldInternalName
            
            #Adding the field to the desired list view
            $vView = $lList.Views[$sViewName]            
            $vView.ViewFields.Add($fieldDisplayName)
            $vView.Update()
        } 
        
        #Disposing SPSite and SPWeb objects
        $spWeb.Dispose()   
        $spSite.Dispose()   

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
} 

#Calling the function
Start-SPAssignment –Global
Add-FieldToList -sListName "<ListName>" -sViewName "<ListView>" -fieldDisplayName "<FieldDisplayName>" -fieldInternalName "<FieldInternalName>" -sfieldType "<FieldType>"
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell