# Disable console progress to support Azure Webjobs and Kudu.
$ProgressPreference="SilentlyContinue";

# Create the Office 365 email credentials.
Write-Output "Creating email authentication credentials..."
$password = ConvertTo-SecureString "ubWm!4261" -AsPlainText -Force;
$credentials = New-Object System.Management.Automation.PSCredential("webmaster@u-btech.com", $password);

# Create and initialize a users dictionary and a codes list.
$usersProcessed = New-Object "System.Collections.Generic.Dictionary[[string],string]";
$codesProcessed = New-Object "System.Collections.Generic.List[string]";

try
{
    # Create and open a new SQL connection.
    Write-Output "Creating SQL connection..."                               
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection('Server=tcp:u-btech-education-sql.database.windows.net,1433;Database=u-btech-education-reports-prod;User ID=u-btech-education-support;Password=@nSDp97C&bf6juBqPgvC;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;');
    $sqlConnection.Open();

    # Create a new SQL command.
    Write-Output "Setting SQL connection parameters..."
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT UserPrincipalName,UserDisplayName FROM ProductActivations WHERE UserPrincipalName LIKE '%hrzedu.org.il'", $sqlConnection);
    $sqlCommand.CommandTimeout = 120;
    

    # Execute the SQL command 
    Write-Output "Running SQL command..."
    $sqlDataset = New-Object System.Data.DataSet;
    $sqlDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($sqlCommand);
    [void]$sqlDataAdapter.fill($sqlDataset);

    # Get all users
    $Users = $sqlDataset.Tables.Rows; 
    
    # Get users that Already sent to them
    $UsersSend = Import-Csv .\UsersSend.csv;

    # Get all codes
    $PlayConCode = Get-Content .\PlayCon.txt;
    
    # Check if have code to sent
    if($PlayConCode -eq $Null){
        Write-Error "There are no codes to divide";
        exit;
    }

    # Populate the processed users dictionary
    $UsersSend | ForEach-Object {$usersProcessed.Add($_.Username,$_.CodeSent)};

    # Populate the processed codes list.
    $PlayConCode | ForEach-Object {$codesProcessed.Add($_)};

    # Run on all users & check if Code Sent to them
    foreach ($u in $Users)
    {   
        
        # Read count values from the list and dictionary.
        $usersCount = $usersProcessed.Count;
        $codesCount = $codesProcessed.Count;

        # Write a logging message.
        Write-Output "Users processed $usersCount and codes available $codesCount";

        # Make sure that we have codes to send.
        if ($usersProcessed.Count -ge $PlayConCode.Count)
        {
            # Don't continue if no more codes are available.
            Write-Output "There are no codes to divide";
            break;
        }

        # Check if user alrady sent code
        if ($usersProcessed.ContainsKey($u.UserPrincipalName))
        {
                Write-Host "the code alrady sent to:" $u.UserPrincipalName;
                continue;
        }

        # User was not sent a code.
        foreach($code in $codesProcessed)
        {
            # Check if the code has already been used.
            if ($usersProcessed.ContainsValue($code))
            {
                    Write-Host "The code has already been used.";
                    continue;
            }                        

            # Add the new user and code to the status dictionary.
            $usersProcessed.Add($u.UserPrincipalName, $code);

            # Read the email 
            [string]$emailbody = Get-Content -Path .\office-template.html -Encoding UTF8;

            # Replace the place holder for the user display name.
            $emailbody = $emailbody.Replace('{0}',$u.UserDisplayName)

            # Replace the place holder for the code.
            $emailbody = $emailbody.Replace('{1}',$code)

            Write-Host "Send code to" $u.UserPrincipalName
            Send-MailMessage -Encoding:Unicode -From:"Webmaster@U-BTech.com" -Body:$emailbody -BodyAsHtml:$true -To:@($u.UserPrincipalName) -SmtpServer:"smtp.office365.com" -Subject:"קוד קופון מתנה" -Priority:High -UseSsl:$true -Port:587 -Credential:$credentials;

            # Remove the code from memory.
            $codesProcessed.Remove($code) | Out-Null;

            # Once we found an unused code, not necessary to move to other codes.
            break;
            
        }
    }

    # Create a CSV file header.
    "Username,CodeSent"| Out-File -FilePath:.\UsersSend.csv -Encoding:UTF8 -Append -Force -Confirm:$false;

    # Dump the contents of the dictionary back to the CSV file.
    foreach ($line in $usersProcessed.Keys)
    {
        # Write each line from the dictionary to the CSV file.
        "$line," + $usersProcessed[$line] | Out-File -FilePath:.\UsersSend.csv -Encoding:UTF8 -Append -Force -Confirm:$false;       
    }

    # Dump all remaining codes to the codes file.
    $codesProcessed | Out-File -FilePath:.\PlayCon.txt;
}
catch
{
    Write-Output "Sending faulty email update...";
    $errorMessage = $_.Exception.Message;
    Write-Host $errorMessage
    
    # send email on error
    Send-MailMessage -Encoding:Unicode -From:"Webmaster@U-BTech.com" -Body:$errorMessage -BodyAsHtml:$true -To:@("Dev@U-BTech.com, Support@U-BTech.com") -SmtpServer:"smtp.office365.com" -Subject:"Send Code Error" -Priority:High -UseSsl:$true -Port:587 -Credential:$credentials;
}