
Login-AzureRmAccount
$Database = Get-AzureRmSqlDatabase -ResourceGroupName "Resource-Test" -ServerName "sqlserver-test-moti" -DatabaseName "sql-test"
Restore-AzureRmSqlDatabase -FromPointInTimeBackup -PointInTime (Get-Date).AddMinutes(-10)  -ResourceGroupName $Database.ResourceGroupName -ServerName $Database.ServerName -TargetDatabaseName "RestoredDatabase" -ResourceId $Database.ResourceID -Edition "Standard" -ServiceObjectiveName "S0"