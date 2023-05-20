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
#Creates a restore point
#------------------------------------------------------------------------------------------------------------------------------------
$Date = ((Get-Date -Format "dd/MM/yyyy"),"_",(Get-Date -Format "HH:mm"))
#Date to be used for name
Enable-ComputerRestore -Drive "C:\"
$LogMessage = "Restore Point: Enabled C: Drive to be restored"; Get-WriteLog
$LogMessage = "Restore Point: Starting Restore"; Get-WriteLog
#Allows restore point to be created on this drive
Checkpoint-Computer -Description 'Cyber_Essentials_Hardening_$Date' -RestorePointType 'MODIFY_SETTINGS'
$LogMessage = "Restore Point: Restore COMPLETED"; Get-WriteLog
#Creates the restore point called Cyber_Essentials_Hardening_$Date