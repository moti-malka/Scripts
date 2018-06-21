#Login-AzureRmAccount

$ResourceGroup = "VmDeployere"
$StartTime = (Get-Date).AddMonths(-1) 
$ResourceGroupName = "VmDeployere"
$VMName = "VmContactSync"

$logs =  Get-AzureRmLog -ResourceGroup $ResourceGroup -StartTime $StartTime -EndTime (Get-Date)

$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status

    if($vm.Statuses.DisplayStatus.Contains("VM deallocated"))
    {
        Write-Output "Theh $VMName not running !"
        exit
    }


    ForEach($log in $logs){
    if($log.Authorization.Action.Equals("Microsoft.Compute/virtualMachines/start/action"))
    { 
        [Datetime]$StartTime = $log.EventTimestamp
        $StartTime  = $StartTime.AddHours(3)
        
        $TimeSpam = New-TimeSpan -Start $StartTime -End (Get-Date)

        Write-Output "UpTime of vm: $TimeSpam"
        exit

    }

}