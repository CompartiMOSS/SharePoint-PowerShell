#http://geekswithblogs.net/bjackett/archive/2011/09/19/powershell-script-to-traverse-all-sites-in-sharepoint-2010-or.aspx

$webs=Get-SPSite -Limit All | Get-SPWeb -Limit All
$webs