
Login-AzureAsAccount

$backup = Get-AzureRmSqlDeletedDatabaseBackup -ServerName "sqlserver-test-moti" -ResourceGroupName "Resource-Test"

foreach($item in $backup){

Write-Host $item.DeletionDate
Write-Host $item.DatabaseName

}




#$deleteddatabase = Get-AzureRmSqlDeletedDatabaseBackup -ResourceGroupName "Resource-Test" -ServerName "sqlserver-test-moti" -DatabaseName "RestoredDatabase"
#$deleteddatabase