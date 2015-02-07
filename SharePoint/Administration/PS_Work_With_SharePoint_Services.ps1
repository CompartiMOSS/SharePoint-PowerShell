############################################################################################################################################
# Script that gets, start and stop all the services in a SharePoint Farm.
# Required Parameters: 
#    ->$sOperationType: Operation type to be done (Read, Stop, Start).
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets, start and stop all the services in a SharePoint Farm.
function WorkWithSharePointServices
{
    param ($sOperationType)
    try
    {
        $spServices=Get-SPServiceInstance
        #Reading Operation
        if($sOperationType -eq "Read"){
            Write-Host "Getting all the services in the farm" -ForegroundColor Green
        }
        #We iterate throught all the services
        foreach ($spService in $spServices){
            switch ($sOperationType) 
            { 
            "Read" {                
                Write-Host $spService.TypeName " - Status: " $spService.Status
                } 
            "Stop" {
                Write-Host "Stopping Service " $spService.TypeName -ForegroundColor Blue
                Stop-SPServiceInstance -Identity $spService -Confirm:$false           
                }
            "Start" {
                Write-Host "Starting Service " $spService.TypeName -ForegroundColor Blue
                Start-SPServiceInstance -Identity $spService
            }         
            default {
                Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
                }
            }
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
WorkWithSharePointServices -sOperationType "Read"
#WorkWithSharePointServices -sOperationType "Stop"
#WorkWithSharePointServices -sOperationType "Start"
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell