#Set Up Variables for BASE FOLDER & DATE

$directory = (Resolve-Path .\).Path                         #Base Directory.Resolve-Path, resolves the wildcard characters in a path, and displays the path contents.
$date = (get-date).ToString("ddMMyyyy")                     #Gets Current Date and converts to a string


#Set Up Variables for LOG FOLDER & LOG FILE

$logfolder = $directory + "\Logs"
$logfile = $logfolder +"\filedeletion-"+$date+".log"


#Set Up Variables for XML File

$xml_file = $directory + "\files_del.xml"                   #xml file path variable
[xml]$xml_content = Get-Content $xml_file                   #Get content of xml file


#Writes to LOG File

Write-Output "-------" >> $logfile;                                                                                                             #Prints the output to log file
Write-Output "$(get-date): Let's Check the Files... "   | Out-File $logfile -Append -Force;                                                     #Prints the output to log file

#FOREACH Loop to check the xml file attributes (Folder Path, Retention Period)

foreach ($xml in $xml_content.GetElementsByTagName("DIRECTORY_RET")){                                                                           #Check XML TAG "DIR_RETENTION"                                                                                                                                                       
    $retention = [int32]$xml.RETENTION                                                                                                          #Assign Retention Variable with method ".RETENTION"
    $delfolder = $xml.DIR                                                                                                                       #Assign Deletion Folders Variable with method ".DIR"
    $check_folder = Test-Path $delfolder                                                                                                        #Assign test path of deletion folder
    if ($check_folder -eq "True") {                                                                                                             #Check if folder exists
    Write-Output "$(get-date): Deleting files at $delfolder with retention pediod of $retention days." | Out-File $logfile -Append -Force;      #If folder exists then it proceeds to next step
    }
    else {                                                                                                                                      #Otherwise it prints error message
        Write-Host "Sorry, the $delfolder does not exist. Please insert a REAL FOLDER!" -ForegroundColor Red
        exit
          }                                                                                                   

#THE EXECUTION RUNS HERE
Get-ChildItem  -File -Recurse $delfolder |                                                                    #Get-ChildItem -> Gets the items and child items in one or more specified locations. -File gets the file & -Recurse goes to child folders as well.  
    Where-Object {$_.LastWriteTime -lt (get-date).AddDays(-$retention) } | ForEach-Object {                                #Where Last Write Time of file, less than current day - retention days with .Adddays method
        $_.fullname | Remove-Item -force                                                                              #Deleting File with fullname method that takes the full path of the file   
        $_.fullname | Out-File $logfile -Append                                                               #Adding the file name to the log
         }
    }                                                                                          
                                                     
#Finally Writes to Log File the end of execution

Write-Output "$(get-date) : Script execution completed " | Out-File $logfile -Append -Force;                  #Prints script execution finish, and write to LOG file
Write-Output "-------" | Out-File $logfile -Append -Force;                                     
