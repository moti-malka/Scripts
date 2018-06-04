# Only required the first time
# ** Azure Resource Manager Powershell Module
#Install-Module AzureRM -force
# ** Azure Security Center Powershell Module
#Install-Module Azure-Security-Center

# Import Azure RM PSM
#Import-Module AzureRM
# Import Azure SecCenter PSM
#Import-Module Azure-Security-Center

# My RG
$resourceGroup = "Development"
# VM that will be started after updating the NSG
$VMName = "u-bdev"
# Get my Public IP
#$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
$ip = "*"
# RDP File
# Hours for access
[int]$hours = 1

$azureAccountName ="moti@u-btech.com"
$azurePassword = ConvertTo-SecureString "Aa0505758244" -AsPlainText -Force

$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

Login-AzureRmAccount -Credential $psCred


# Get Sub Info and select Subscription
#$SubscriptionName = Get-AzureRmSubscription 
#Select-AzureRmSubscription -TenantId $SubscriptionName.TenantId

# Request Access to the VM for current IP Address for RDP for 2 hours
Invoke-ASCJITAccess -ResourceGroupName $resourceGroup -VM $VMName -Port 5986 -Hours $hours -AddressPrefix $ip 
