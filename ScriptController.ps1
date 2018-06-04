 param (
    [Parameter(Mandatory=$true)]
    [string]$Action
    
 )

 if($Action -eq "install"){
    Start-Process powershell -verb runas -ArgumentList "-file C:\ReleaseScript\StartProcess.ps1" 
 }
 if($Action -eq "delete"){
    Start-Process powershell -verb runas -ArgumentList "-file C:\ReleaseScript\Deleteprogram.ps1"
 }
 if($Action -eq "CheckIfInstalled"){
    Start-Process powershell -verb runas -ArgumentList "-file C:\ReleaseScript\CheckIfProgramInstall.ps1"
 }