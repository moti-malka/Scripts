# DB details
$resourceGroup = "Resource-Test"
$Servername = "sqlserver-test-moti"
$DBName = "RestoredDatabase"

# DB Cred 
$DbAdmin = "motim"
$azurePassword = ConvertTo-SecureString "Aa0505758244" -AsPlainText -Force

# Key to export database
$StorageKey = "0QW2Y9tUX/ygavie8cqsiQQQcmzgxMfzaeL3TxzrbYVslYBY/egtY8dXFA1wcB+HRzxX6U/4B2fBklSwzmEr2w=="
$StorageUri = "https://dbbackuptest.blob.core.windows.net/dbbackuptest/"
$StorageUri += $DBName
$StorageUri+= ".bacpac"

# Storage details
$containerName = "dbbackuptest"
$connectionString = "DefaultEndpointsProtocol=https;AccountName=dbbackuptest;AccountKey=0QW2Y9tUX/ygavie8cqsiQQQcmzgxMfzaeL3TxzrbYVslYBY/egtY8dXFA1wcB+HRzxX6U/4B2fBklSwzmEr2w==;EndpointSuffix=core.windows.net"

# Create Contex
$storage_account = New-AzureStorageContext -ConnectionString $connectionString


        try{

            # Get all blobs in container
            $blob =  Get-AzureStorageContainer -Name $containerName -Context $storage_account | Get-AzureStorageBlob 
 
             if($blob -eq $null){
                  New-AzureRmSqlDatabaseExport -ResourceGroupName $resourceGroup `
                     -ServerName $Servername `
                     -DatabaseName $DBName `
                     -StorageKeyType "StorageAccessKey" `
                     -StorageKey $StorageKey `
                     -StorageUri $StorageUri `
                     -AdministratorLogin $DbAdmin `
                     -AdministratorLoginPassword $azurePassword
                       exit
                    }


            #file name
            $DbExportNmae = $DBName
            $DbExportNmae += ".bacpac"

                foreach($file in $blob){
        
                    if($file.Name -eq $DbExportNmae){
                          Remove-AzureStorageBlob -Container $containerName -Blob $file.Name -Context $storage_account 
 
                        }
                        New-AzureRmSqlDatabaseExport -ResourceGroupName $resourceGroup `
                         -ServerName $Servername `
                         -DatabaseName $DBName `
                         -StorageKeyType "StorageAccessKey" `
                         -StorageKey $StorageKey `
                         -StorageUri $StorageUri `
                         -AdministratorLogin $DbAdmin `
                         -AdministratorLoginPassword $azurePassword
                           exit
         
                }

             }

        catch
        {
            $MessageError = $_.Exception.Message
            Write-Host $MessageError -ForegroundColor red -NoNewline
            exit

        }

