# Only required the first time
# ** Azure Resource Manager Powershell Module
Install-Module AzureRM -force
# ** Azure Security Center Powershell Module
Install-Module Azure-Security-Center

# Import Azure RM PSM
Import-Module AzureRM
# Import Azure SecCenter PSM
Import-Module Azure-Security-Center

# My RG
$resourceGroup = "Development"
# VM that will be started after updating the NSG
$VMName = "u-bdev"
# Get my Public IP
$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
# RDP File
$RDPFile = "C:\Users\Darren~1\Desktop\MyRDPFile.rdp" 
# Hours for access
[int]$hours = 3

Login-AzureRmAccount 

# Get Sub Info and select Subscription
$SubscriptionName = Get-AzureRmSubscription 
Select-AzureRmSubscription -TenantId $SubscriptionName.TenantId

# Request Access to the VM for current IP Address for RDP for 2 hours
Invoke-ASCJITAccess -ResourceGroupName $resourceGroup -VM $VMName -Port 3389 -Hours $hours -AddressPrefix $ip 

# Start VM
$vm = Get-AzureRmVM -ResourceGroupName $resourceGroup -Name $VMName -Status 
$PowerState = (get-culture).TextInfo.ToTitleCase(($vm.statuses)[1].code.split("/")[1])
if ($PowerState -eq "Deallocated"){
    $vmstatus = Start-AzureRMVM -ResourceGroupName $resourceGroup -Name $VMName
}

# Connect to VM using RDP Settings File
if($vmstatus.Status.Equals("Succeeded")){
    # Give it 2 mins to start up fully. It takes a while if the machine has been offline 
    Start-Sleep 120
    Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList $RDPFile
}
else{
    write-host "Something went wrong starting $VMName" -foregroundcolor "magenta" -backgroundcolor "yellow"
}

# Stop VM 
# Stop-AzureRMVM -ResourceGroupName $resourceGroup -Name $VMName