# DB details
$resourceGroup = "Resource-Test"
$Servername = "sqlserver-test-moti"
$DBName = "RestoredDatabase"

# DB Cred 
$DbAdmin = "motim"
$azurePassword = ConvertTo-SecureString "Aa0505758244" -AsPlainText -Force

# Key to Impoert database from storage
$StorageKey = "0QW2Y9tUX/ygavie8cqsiQQQcmzgxMfzaeL3TxzrbYVslYBY/egtY8dXFA1wcB+HRzxX6U/4B2fBklSwzmEr2w=="
$StorageUri = "https://dbbackuptest.blob.core.windows.net/dbbackuptest/"
$StorageUri += $DBName
$StorageUri+= ".bacpac"

# Storage details
$containerName = "dbbackuptest"
$connectionString = "DefaultEndpointsProtocol=https;AccountName=dbbackuptest;AccountKey=0QW2Y9tUX/ygavie8cqsiQQQcmzgxMfzaeL3TxzrbYVslYBY/egtY8dXFA1wcB+HRzxX6U/4B2fBklSwzmEr2w==;EndpointSuffix=core.windows.net"

# Create Contex
$storage_account = New-AzureStorageContext -ConnectionString $connectionString

$OldDBExists = $false;

        try{

             # Get all blobs (files) in container
             $blob =  Get-AzureStorageContainer -Name $containerName -Context $storage_account | Get-AzureStorageBlob 
             
             # Chack if container is not empty
             if($blob -eq $null){
                Write-Error "The storage is empty !"
                exit
            }

                # get all database on server
                $allDBOnServer = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroup `
                                                        -ServerName $Servername;

                foreach($db in $allDBOnServer)
                {
                    
                    #if database alrady exists
                    if($db.DatabaseName -eq $DBName)
                       {
                        Write-Output "DB $DBName exists"
                        $OldDBExists = $true
                        break
                       
                       }
                }

                #Get bacpac file
                foreach($file in $blob){
                
                    #set temp name for new db
                    $OldDbName = $DBName
                    $OldDbName += "TempName"
                    $OldDbName += (get-date).ToString("M_d_hh_mm")

                    $tempName = $DBName
                    $tempName += ".bacpac"
                                    
                    if($file.Name -eq $tempName){
                       
                       Write-Output "BacPac file found... starting BackUP..."
                       Write-Output "Create new DataBase $OldDbName"

                       #Create New DataBase
                       New-AzureRmSqlDatabase  -ResourceGroupName $resourceGroup `
                                               -ServerName $Servername `
                                               -DatabaseName $OldDbName `
                                               -RequestedServiceObjectiveName "s0" `
                                               -ErrorAction Stop



                       New-AzureRmSqlDatabaseImport -ResourceGroupName $resourceGroup `
                         -ServerName $Servername `
                         -DatabaseName $OldDbName `
                         -StorageKeyType "StorageAccessKey" `
                         -StorageKey $StorageKey `
                         -StorageUri $StorageUri `
                         -AdministratorLogin $DbAdmin `
                         -AdministratorLoginPassword $azurePassword `
                         -Edition "standard" `
                         -ServiceObjectiveName "s0" `
                         -DatabaseMaxSizeBytes 2684354560000 `
                         -ErrorAction Stop
                         
                         
                         Write-Output "Restore from BacPac file finish !"
                         

                         # Delete old DB if exists 
                         if($OldDBExists)
                         {
                            Write-Output "Delete old DataBase..."

                            #delete old DB 
                            Remove-AzureRmSqlDatabase -ResourceGroupName $resourceGroup `
                             -ServerName $Servername `
                             -DatabaseName $DBName `
                             -Force `
                             -ErrorAction Stop

                         
                         }

                         #Rename name of new database

                         Write-Output "Rename databae $OldDbName to $DBName"
                         Set-AzureRmSqlDatabase -ResourceGroupName $resourceGroup `
                                                -ServerName $Servername `
                                                -DatabaseName $OldDbName `
                                                -NewName $DBName `
                                                -ErrorAction Stop
                                                
                         exit
         
                        }
                      }
                    }
                  
                

        catch
        {
            $MessageError = $_.Exception.Message
            Write-Host $MessageError -ForegroundColor red -NoNewline
            exit

        }

