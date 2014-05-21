############################################################################
#
#	Script:				Find-WebPartPages.ps1
#	Author:				Sean Kelley 
#	Create Date: 		10/5/2010
#	Requirements:		PowerShell 2.0 and MOSS 2007. 
#
#	Details:			This script takes a SQL server name, 2007 SharePoint config DB name and a webpart GUID to locate.
#						The actual pages that the webpart is on are returned. This script assumes that all content dbs are
#						located on the same SQL server as the config DB.
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

Write-Host "`nFind WebPart Pages" 
Write-Host "*******************************************`n" 

$dbname = Read-Host -prompt "SharePoint ConfigDB Name"
$dbserver = Read-Host -prompt "SQL Server"
$webpartid = Read-Host -prompt "Webpart GUID"

[IO.Directory]::SetCurrentDirectory((Convert-Path (Get-Location -PSProvider FileSystem)))
$current_directory = Convert-Path (Get-Location -PSProvider FileSystem)

$filedate = get-date -format "M-d-yyyy_hh-mm-ss"
$filename = "webpart_location_report_for_guid_" + $webpartid + "_" + $filedate + ".csv"

$script:webpart_location_report = $current_directory + "\" + $filename

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = 'server=' + $dbserver + ';integrated security=TRUE;database=' + $dbname
$SqlConnection.Open()

$query = @"
	
	create table ##webpartinventory
    (
    [location] nvarchar(500),
    [TP_partorder] INT,
    [tp_zoneid] varchar(100),
    [tp_isincluded] bit,
    [tp_webparttypeid] uniqueidentifier,
    [content_db] varchar(100)
    )
    
    CREATE TABLE #DBNamesLL  
                    (DatabaseName VARCHAR(800),  
                    RecStatus INT Default 0  
                    )  
    DECLARE @cmdStr NVARCHAR(2000)  
    DECLARE @dbName VARCHAR(500)  

    INSERT INTO #DBNamesll (DatabaseName)  
    SELECT [Name] FROM sys.databases where state_desc = 'online'
    ORDER by [Name] ASC  

    WHILE EXISTS (SELECT * FROM #DBNamesLL 
                    WHERE RecStatus=0)  
    BEGIN  

                SELECT TOP 1 @DbName=DatabaseName  
                FROM #DBNamesLL  
                WHERE RecStatus=0  

    SELECT @cmdStr = N'USE ' + quotename(@dbName, '[') + N';'  
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'IF EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES with (NOLOCK) WHERE TABLE_NAME = ''namevaluepair'')'
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'BEGIN'
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'INSERT INTO ##webpartinventory'
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'SELECT ' 
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'CASE WHEN (DATALENGTH(Docs.DirName) = 0) THEN Docs.LeafName WHEN (DATALENGTH(Docs.LeafName) = 0) THEN Docs.DirName ELSE Docs.DirName + N''/'' + Docs.LeafName END [location],'   
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'WebParts.tp_PartOrder,  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'WebParts.tp_ZoneID,   '           
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'WebParts.tp_IsIncluded, ' 
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'WebParts.tp_WebPartTypeId,'''
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + @dbname + ''' as [content_db] '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'FROM  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'WebParts with (NOLOCK) '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'INNER JOIN  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'Docs with (NOLOCK) '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'ON  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'Docs.SiteId = WebParts.tp_SiteID AND  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'Docs.Id = WebParts.tp_PageUrlID AND  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'Docs.Level = WebParts.tp_Level AND  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'Docs.Level = 1 AND  '
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'WebParts.tp_UserID IS NULL   ' 
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'where tp_webparttypeID = ''
"@
$query = $query + $webpartid 
$query = $query + @"
'''
    SELECT @cmdStr = @cmdStr + CHAR(13)+CHAR(10) + 'END'

    EXEC sp_executesql @Cmdstr  

    UPDATE #DBNamesLL
    SET RecStatus=1  
    WHERE RecStatus=0  
    AND DatabaseName=@DbName  

    END
"@ 

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $query
$SqlCmd.Connection = $SqlConnection
$SqlCmd.ExecuteNonQuery() | Out-Null

#now gather the results 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = "select REPLACE(REPLACE(REPLACE(content_db, CHAR(10), ''), CHAR(13), ''), CHAR(9), '') as content_db, location, tp_partorder, tp_zoneid from ##webpartinventory order by content_db, location asc"
$SqlCmd.Connection = $SqlConnection

$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet) | Out-Null 

$results = $DataSet.Tables[0]

if($results.Rows.Count -gt 0)
{
	Write-Host "`nFound $($results.Rows.Count) instances of webpart id $($webpartid) installed."
	foreach($result in $results.Rows)
	{
		#Write-Host $result.content_db $result.location $result.tp_partorder $result.tp_zoneid
		
	}
	
	Write-Host "`nWriting results to $script:webpart_location_report" -ForegroundColor Green
	$results.Rows 
	$results.Rows | Export-Csv -Path $script:webpart_location_report -NoTypeInformation
		
	Write-Host "`nFinished finding webparts. Opening report." -ForegroundColor DarkGreen
	& "$($script:webpart_location_report)"
}
else	#we didnt find anything
{
	Write-Host "`nNo results found for webpartid $($webpartid)." -ForegroundColor Red -BackgroundColor Black
}


#clenaup / drop the temp table
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = "DROP TABLE ##webpartinventory" 
$SqlCmd.Connection = $SqlConnection
$SqlCmd.ExecuteNonQuery() | Out-Null

$SqlConnection.Close()

