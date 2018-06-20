# -- run only in first use --#
#Get-Module -ListAvailable AzureRM


<#
Param(
  #-- 3 firsts parameter using for get DB to restore 
  [Parameter(Mandatory=$True,HelpMessage="ResourceGroup of db to restore",Position=1) ]
  [string]$ResourceGroup,

  [Parameter(Mandatory=$True,HelpMessage="Server name of DB to restore",Position=2)]
  [string]$ServerName,

  [Parameter(Mandatory=$True,HelpMessage="Db name to restore",Position=3)]
  [string]$DbName,

  # parameter to to Configure PIT to restore
  [Parameter(Mandatory=$true, HelpMessage="Date to restore, format:i.e dd/mm/yyyy",position=4)]
  [DateTime]$DateToRestore,

  [parameter(Mandatory=$true, HelpMessage= "Time to restore, format:i.e for 13:00:00 insert 13 ", position=5)]
  [string]$HourseToRestore,

  [Parameter(Mandatory=$true, HelpMessage="specify minutes to restore format:i.e for 13:25:00 insert 25", position=6)] 
  [string]$MinutesToRestore,

  # param where RG to create DB
  [Parameter(Mandatory=$true, HelpMessage="Resource group to create DB", position=7)]
  [string]$ResourceToRestore,

  # name for new DB 
  [Parameter(Mandatory=$true, HelpMessage="Name for new DB", position=8)]
  [string]$NewDbName


)
#>

$ResourceGroup = "Resource-Test";

$ServerName = "sqlserver-test-moti";

$DbName = "new-db-test-2018-6-18-15-34";

[DateTime]$DateToRestore = "06/18/2018 13:30:00";


    try
        {

        #add hourse to date
        #$DateToRestore = $DateToRestore.AddHours($HourseToRestore);

        #add minutes to Date
        #$DateToRestore = $DateToRestore.AddMinutes($MinutesToRestore);
        
        #login to Azure
        #Login-AzureRmAccount

       
        # Get all DB on selected server 
        $allDBOnServer = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName;
        
        
        #Check if DB Exist & run on server
        foreach($Db in $allDBOnServer){
            
            #if DataBase exist on server 
            if($Db.DatabaseName -eq $DbName){
            
              # if Database PIT validat
              if($Db.EarliestRestoreDate -le $DateToRestore){
                    
                    
                    #Get Db to restore
                    $DatabaseToRestore = Get-AzureRmSqlDatabase -ResourceGroupName $Db.ResourceGroupName -ServerName $Db.ServerName -DatabaseName $Db.DatabaseName    
                    
                    #set temp name for new db
                    $OldDbName = $DbName
                    $OldDbName += "TempName"
                    $OldDbName += (get-date).ToString("M_d_hh_mm")

                    Write-Output "starting restore $DbName from existing database please wait..."
                    
                    # Restore DB & create new one
                    Restore-AzureRmSqlDatabase -FromPointInTimeBackup -PointInTime $DateToRestore -ResourceGroupName $DatabaseToRestore.ResourceGroupName -ServerName $DatabaseToRestore.ServerName -TargetDatabaseName $OldDbName -ResourceId $DatabaseToRestore.ResourceID -Edition $DatabaseToRestore.Edition -ServiceObjectiveName $DatabaseToRestore.CurrentServiceObjectiveName
                    
                    # chack if restore success
                    $CheckIfDbRestore = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName -DatabaseName $OldDbName

                    #if Db exist
                    if($CheckIfDbRestore){

                        #delete old DB 
                        Remove-AzureRmSqlDatabase -ResourceGroupName $DatabaseToRestore.ResourceGroupName -ServerName $DatabaseToRestore.ServerName -DatabaseName $DatabaseToRestore.DatabaseName -Force
                    
                        #rename dataBase of new DB 
                        Set-AzureRmSqlDatabase -ResourceGroupName $Db.ResourceGroupName -ServerName $Db.ServerName -DatabaseName $OldDbName -NewName $DbName
                        Write-Output "rename finish successfuly."

                        exit
                    
                    }
                    
                    
                }
              
            }
        }


            #get all deleted DB
            $AllDeletedDB = AzureRmSqlDeletedDatabaseBackup -ResourceGroupName $ResourceGroup -ServerName $ServerName 
            
            #check if database exists
            foreach($DeletedDB in $AllDeletedDB){
             
             #id database exists
             if($DeletedDB.DatabaseName -eq $DbName){
                
                if($DeletedDB.RecoveryPeriodStartDate -le $DateToRestore){
                
                
                #Set temp name for new db
                $OldDbName = $DbName
                $OldDbName += "TempName"
                $OldDbName += (get-date).ToString("M_d_hh_mm")
                
                Write-Output "starting restore from $DbName deleted.... "
                
                #Restore database from deleted db
                Restore-AzureRmSqlDatabase -FromDeletedDatabaseBackup -DeletionDate $DeletedDB.DeletionDate -ResourceGroupName $DeletedDB.ResourceGroupName -ServerName $DeletedDB.ServerName  -TargetDatabaseName $OldDbName -ResourceId $DeletedDB.ResourceID -Edition $DeletedDB.Edition -ServiceObjectiveName $DeletedDB.ServiceLevelObjective -PointInTime $DateToRestore 
                
                    #chack if restore success
                    $newDB = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName -DatabaseName $OldDbName

                    #Get all existing database
                    $getAllDb = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName
                    
                    #check if db with same name exists
                    foreach($DB in $getAllDb){
                    
                    #if Db exist
                    if($DB.DatabaseName -eq $DbName){

                        Write-Output "deleted old database $DbName..."

                        #delete old DB 
                        Remove-AzureRmSqlDatabase -ResourceGroupName $DB.ResourceGroupName -ServerName $DB.ServerName -DatabaseName $DB.DatabaseName -Force
                        
                        Write-Output "rename $OldDbName dataBase to $DbName..."
                        
                        #rename new dataBase to original name
                        Set-AzureRmSqlDatabase -ResourceGroupName $DB.ResourceGroupName -ServerName $DB.ServerName -DatabaseName $OldDbName -NewName $DbName

                        Write-Output "rename finish successfuly."

                        exit
                        
                        }
                        Write-Output "rename $OldDbName to $DbName..."
                        
                        #rename new dataBase to original name
                        Set-AzureRmSqlDatabase -ResourceGroupName $DB.ResourceGroupName -ServerName $DB.ServerName -DatabaseName $OldDbName -NewName $DbName

                        Write-Output "rename finish successfuly."
                        exit

                      }
                    }
                  }
                }
              }
            

  catch
       {
        $MessageError = $_.Exception.Message
        Write-Host $MessageError -ForegroundColor red -NoNewline
        exit
       }
