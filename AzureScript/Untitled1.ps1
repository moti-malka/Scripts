
$connectionString = "Server=tcp:sqlserver-test-moti.database.windows.net,1433;Initial Catalog=RestoredDatabase;Persist Security Info=False;User ID={your_username};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30";
$Ctx = New-AzureSqlDatabaseServerContext -ConnectionString $connectionString
Get-AzureStorageTable –Context $Ctx | select Name