#------------------------------------------------------------------------------------------------------------------------------------
#Function to save to report
#------------------------------------------------------------------------------------------------------------------------------------
function Get-WriteReport{
#This is a function to save to the report file
    $ReportText | Out-File -FilePath .\Cyber_Essentials_Hardening_Report_*.txt -Append
    #Add the message to the file
}
#------------------------------------------------------------------------------------------------------------------------------------
#Function to save to log
#------------------------------------------------------------------------------------------------------------------------------------
function Get-WriteLog{
#This is a function to save to a log file
    $LogTime = (Get-Date -Format "HH:mm:ss.ffff")+ (" - ")
    #Time for log
    $LogTime+ $LogMessage | Out-File -FilePath .\Log_*.txt -Append
    #Add the log time and message to the file
}

#------------------------------------------------------------------------------------------------------------------------------------
#Responsible entering the main data to the report
#------------------------------------------------------------------------------------------------------------------------------------

$ReportText = ("Windows Edition: ")+ (Get-Computerinfo).OsName; Get-WriteReport
$LogMessage = ("Report: Windows Edition Found"); Get-WriteLog

$ReportText = ("Windows Version: ")+ (Get-Computerinfo).OSDisplayVersion; Get-WriteReport
$LogMessage = ("Report: Windows Version Found"); Get-WriteLog

$ReportText = ("Windows Build: ")+ (Get-Computerinfo).OsBuildNumber; Get-WriteReport
$LogMessage = ("Report: Windows Build Found"); Get-WriteLog

$ReportText = ("Machine Name: ")+ (Get-Computerinfo).CsName; Get-WriteReport
$LogMessage = ("Report: Machine Name Found"); Get-WriteLog

$ReportText = "================================================================="; Get-WriteReport
$AllUsers=@((Get-LocalUser).name)
$ReportText = ("All users on machine:"); Get-WriteReport
$LogMessage = ("Report: Found " + $AllUsers.Count + " users"); Get-WriteLog
for( $i = 0; $i -lt $AllUsers.Count; $i++ ){
    $ReportText = ($AllUsers[$i]); Get-WriteReport}

$ReportText = "================================================================="; Get-WriteReport
winget list --accept-source-agreements;
$ReportText = winget list; Get-WriteReport
$LogMessage = ("Report: Found " + $ReportText.Count + " apps installed"); Get-WriteLog

