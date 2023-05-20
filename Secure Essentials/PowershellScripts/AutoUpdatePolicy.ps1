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
#Set Automatic Updates
#------------------------------------------------------------------------------------------------------------------------------------
#https://learn.microsoft.com/de-de/security-updates/windowsupdateservices/18127499

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate";
#Set the desriedd path
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
#Find the path. If not found, create it
$LogMessage = ("Automatic Updates Policy Update: New registry edit created at " + $registryPath); Get-WriteLog

$PolicyName=@(
"ConfigureDeadlineForFeatureUpdates",
"ConfigureDeadlineForQualityUpdates",
"ConfigureDeadlineGracePeriod")

$PolicyValue=@("7","3","2")

for( $i = 0; $i -lt $PolicyName.Count; $i++ ){
#While i is less than the length of "PolicyName", loop
    New-ItemProperty -Path $registryPath -Name $PolicyName[$i]  -Value $PolicyValue[$i] -PropertyType DWORD -Force;
    #create a new item under the path
    $LogMessage = ("Automatic Updates Policy Update: " + $PolicyName[$i] + " set to " + $PolicyValue[$i]); Get-WriteLog
}

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU";
#Set the desriedd path
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
#Find the path. If not found, create it
$LogMessage = ("Automatic Updates Policy Update: New registry edit created at " + $registryPath); Get-WriteLog

$PolicyName=@(
"NoAutoUpdate",
"AutoInstallMinorUpdates")

$PolicyValue=@("3","1")

for( $i = 0; $i -lt $PolicyName.Count; $i++ ){
#While i is less than the length of "PolicyName", loop
    New-ItemProperty -Path $registryPath -Name $PolicyName[$i]  -Value $PolicyValue[$i] -PropertyType DWORD -Force;
    #create a new item under the path
    $LogMessage = ("Automatic Updates Policy Update: " + $PolicyName[$i] + " set to " + $PolicyValue[$i]); Get-WriteLog
}
