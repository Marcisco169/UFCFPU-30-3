Add-Type -AssemblyName PresentationCore,PresentationFramework
#Used for the pop up message box

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

$NoError = $false

#------------------------------------------------------------------------------------------------------------------------------------
#Responsible for creating report and log file
#------------------------------------------------------------------------------------------------------------------------------------

$Date = (Get-Date -UFormat "%d_%m_%Y")
#Gets date using _ not / as it cannot be used in a file name

New-Item (".\Log_$Date.txt") -force
#Creates the log in the current directory with todays date
$LogMessage = "Log file created"; Get-WriteLog
#Creates the log message

try {
    New-Item (".\Cyber_Essentials_Hardening_Report_$Date.txt") -force 
    $LogMessage = "Cyber_Essentials_Hardening_Report_$Date.txt file created"; Get-WriteLog
    #Creates the log message
}
catch {
    $LogMessage = "An error occurred whilst creating the report file"; Get-WriteLog
    $NoError = $true
}

#------------------------------------------------------------------------------------------------------------------------------------
#Executes each script here
#------------------------------------------------------------------------------------------------------------------------------------

If ($NoError -eq $false){
    <#
    $TempMessage = " failed to execute"

    try{& .\GenerateReport.ps1}
    catch{$LogMessage = ("Generate report" + $TempMessage); Get-WriteLog }

    try{
        & .\PasswordPolicy.ps1
    }
    catch{
        $LogMessage = ("Password Policy" + $TempMessage); Get-WriteLog 
    }
    #>

    $Location = Get-Location

    & $Location\PowershellScripts\RestorePoint.ps1
    & $Location\PowershellScripts\GenerateReport.ps1
    & $Location\PowershellScripts\PasswordEnforcePolicy.ps1
    & $Location\PowershellScripts\AutoUpdatePolicy.ps1
    & $Location\PowershellScripts\SecurityPolicies.ps1
    & $Location\PowershellScripts\AntiVirusConfiguration.ps1

    $messageicon = "information"
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Hardening Completed"
    $Messageboxbody = "The hardening has been completed. Please refer to the report and logs to learn what has been done to the system."
    [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)
} 

else
{
    $messageicon = "error"
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Error"
    $Messageboxbody = "An error has occured during setup. Please try again!"
    [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)
}
    

