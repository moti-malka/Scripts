param
(
    [parameter(mandatory=$false)]
    [object]$WebhookData
)

$azureAccountName ="moti@u-btech.com"
$azurePassword = ConvertTo-SecureString "Aa0505758244" -AsPlainText -Force

$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

Login-AzureRmAccount  -Credential $psCred


$Request = (ConvertFrom-Json -InputObject $WebhookData.RequestBody);

Write-Output $Request.context

$ResourceGroup =  $Request.context.resourceGroupName

$ServerAndDatabase = $Request.context.resourceId 

$Server = $ServerAndDatabase.split('/')[8];

$DataBase = $ServerAndDatabase.split('/')[10];

write-output "RG: $ResourceGroup"
write-output "Server: $Server"
write-output "DB: $DataBase"

try{
        $DB = Get-AzureRmSqlDatabase `
                -DatabaseName $DataBase `
                -ServerName $Server `
                -ResourceGroupName $ResourceGroup

        if($DB.RequestedServiceObjectiveName -ne "s2"){

            Write-output "Change Database Edition to s2"
            
            Set-AzureRmSqlDatabase `
                    -MaxSizeBytes $DB.MaxSizeBytes `
                    -RequestedServiceObjectiveName "s2" `
                    -ServerName $Server `
                    -DatabaseName $DataBase `
                    -ResourceGroupName $ResourceGroup `
                    -Edition $DB.Edition    

        }

        $password = ConvertTo-SecureString "Password" -AsPlainText -Force;
        $credentials = New-Object System.Management.Automation.PSCredential("Mail from", $password);
        Send-MailMessage -Encoding:Unicode -From:"Mail From" -Body:"finish successfully scale up database" -To:@("Mail Send To") -SmtpServer:"smtp.office365.com" -Subject:"Finish scale up $DataBase" -Priority:High -UseSsl:$true -Port:587 -Credential:$credentials;
    }

    catch
    {
        $errorMessage = $_.Exception.Message;
        Write-Output $errorMessage
    }
        