#get all file in ContactSync folder
Get-ChildItem "C:\Program Files\U-BTech Solutions LTD\ContactSync" -Filter *.* | 

# loop on all file 
Foreach-Object {
    
        #check if file is U-btech product
        if($_.Name -match "UBTech")
         {
           #check if asambly file is protected or not
           ildasm.exe $_.FullName "/output:MyFile.il"
            
           $outPut = $psise.CurrentPowerShellTab.ConsolePane.text
           if ($Text -match "Protected module -- cannot disassemble"){
                Write-Host "the file "$_.Name" is Protected!"
           }
           else{
            Write-Error "the file "$_.Name" is Not Protected!!!"

           }
           
          
         } 
 }
   
 


