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
#Only allows administrators to install apps
#------------------------------------------------------------------------------------------------------------------------------------
$registryPath ="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx"
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
New-ItemProperty -Path $registryPath -Name "BlockNonAdminUserInstall"  -Value "1" -PropertyType DWORD -Force;
$LogMessage = ("Security Policy Update: New registry edit created at $registryPath"); Get-WriteLog
$LogMessage = ("Security Policy Update: Block NonAdminUser Install set to TRUE"); Get-WriteLog

#------------------------------------------------------------------------------------------------------------------------------------
#Do not allow users to use MS Store
#------------------------------------------------------------------------------------------------------------------------------------
#ENTERPRISE AND EDUCATION ONLY
$registryPath ="HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
New-ItemProperty -Path $registryPath -Name "RemoveWindowsStore"  -Value "1" -PropertyType DWORD -Force;
$LogMessage = ("Security Policy Update: New registry edit created at $registryPath"); Get-WriteLog
$LogMessage = ("Security Policy Update: Remove Windows Store set to TRUE"); Get-WriteLog
#------------------------------------------------------------------------------------------------------------------------------------
#Do not allow users to use MS Store Apps
#------------------------------------------------------------------------------------------------------------------------------------
#ENTERPRISE AND EDUCATION ONLY
#Prevents users from accessing settings
<#
$registryPath ="HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
New-ItemProperty -Path $registryPath -Name "DisableStoreApps"  -Value "1" -PropertyType DWORD -Force;
#>

#------------------------------------------------------------------------------------------------------------------------------------
#Disable autorun/autoplay
#------------------------------------------------------------------------------------------------------------------------------------
$registryPath ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer"
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
New-ItemProperty $registryPath -Name "NoDriveTypeAutorun" -Value "0" -PropertyType DWORD -Force;
$LogMessage = ("Security Policy Update: New registry edit created at $registryPath"); Get-WriteLog
$LogMessage = ("Security Policy Update: No Drive Type Autorun/AutoPlay set to TRUE"); Get-WriteLog