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
#Determin what antivirus is installed
#------------------------------------------------------------------------------------------------------------------------------------
$WDConfig = $False

$AVProduct=@((Get-CimInstance -Namespace root/SecurityCenter2 -Classname AntiVirusProduct).displayName)
$AVStatus=@((Get-CimInstance -Namespace root/SecurityCenter2 -Classname AntiVirusProduct).productState)
#An array of all installed antivirus products and their status

#A check must be done to see which AV is running as there could be nothing or multiple AV running

for( $i = 0; $i -lt $AVProduct.Count; $i++ ){
#Loops through all installed products to check if they are running
    switch ($AVStatus[$i]) { 
        "262144" {$defstatus = "Up to date" ;$rtstatus = "Disabled"} 
        "262160" {$defstatus = "Out of date" ;$rtstatus = "Disabled"} 
        "266240" {$defstatus = "Up to date" ;$rtstatus = "Enabled"} 
        "266256" {$defstatus = "Out of date" ;$rtstatus = "Enabled"} 
        "393216" {$defstatus = "Up to date" ;$rtstatus = "Disabled"} 
        "393232" {$defstatus = "Out of date" ;$rtstatus = "Disabled"} 
        "393488" {$defstatus = "Out of date" ;$rtstatus = "Disabled"} 
        "397312" {$defstatus = "Up to date" ;$rtstatus = "Enabled"} 
        "397328" {$defstatus = "Out of date" ;$rtstatus = "Enabled"} 
        "397584" {$defstatus = "Out of date" ;$rtstatus = "Enabled"} 
        "397568" {$defstatus = "Up to date"; $rtstatus = "Enabled"}
        "393472" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
        default {$defstatus = "Unknown" ;$rtstatus = "Unknown"} 
        #SOURCE - https://www.404techsupport.com/2015/04/27/powershell-script-detect-antivirus-product-and-status/
    }

    if ($rtstatus -eq "Enabled"){
    #Enter the current antivirus check into an array because it's enabled
        $RunningAV=@($AVProduct[$i])
        $LogMessage = ("AV Product: Found $AVProduct[$i] running on the system"); Get-WriteLog
    } 
}

if ($RunningAV.Count -eq 0){
#If RunningAV is 0, no antivirus is enabled!
    Set-MpPreference -DisableRealtimeMonitoring $false
    $WDConfig = $True

}elseif ($RunningAV.Count -gt 1){
#If RunningAV is greater than 1, more than 1 AV service is enabled and may cause problems
    $LogMessage = ("Two or more AV products are running. To avoid issues, please consider only using one product"); Get-WriteLog

}else {
    #Only 1 AV product is running
    If ($RunningAV -ne "Windows Defender"){
    #Check if it is Windows Defender Running
        $LogMessage = ("$RunningAV is installed. Unable to configure this product. Please configure it manually."); Get-WriteLog

    }else {
        $LogMessage = ("Defender is running. Configuration beginning."); Get-WriteLog
        $WDConfig = $True
    }
}

#------------------------------------------------------------------------------------------------------------------------------------
#Configuring Windows Defender
#------------------------------------------------------------------------------------------------------------------------------------
If ($WDConfig -eq $True){

    #------------------------------------------------------------------------------------------------------------------------------------
    #Enabling features
    #------------------------------------------------------------------------------------------------------------------------------------

    Set-MpPreference -DisableRealtimeMonitoring $false
    #Ensures real time monitoring is enabled
    $LogMessage = ("AV Configuration: Real Time Monitoring ENABLED"); Get-WriteLog

    Set-MpPreference -DisableRemovableDriveScanning $false
    #Ensures removable drives are scanned when connected
    $LogMessage = ("AV Configuration: Removable Drive Scanning ENABLED"); Get-WriteLog

    Set-MpPreference -CheckForSignaturesBeforeRunningScan $true
    #Checks for new virus and spyware definitions before Windows Defender runs a scan
    $LogMessage = ("AV Configuration: Check For Signatures Before Scan ENABLED"); Get-WriteLog

    Set-MpPreference -DisableEmailScanning $false
    #Parses the mailbox and mail files, according to their specific format, in order to analyze mail bodies and attachments
    $LogMessage = ("AV Configuration: Email Scanning ENABLED"); Get-WriteLog    

    Set-MpPreference -DisableArchiveScanning $false
    #Scans within compressed files
    $LogMessage = ("AV Configuration: Archive Scanning ENABLED"); Get-WriteLog

    $registryPath ="HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
    New-ItemProperty $registryPath -Name "DisableAntiSpyware" -Value "0" -PropertyType DWORD -Force;
    $LogMessage = ("AV Configuratio: New registry edit created at $registryPath"); Get-WriteLog
    $LogMessage = ("AV Configuratio: Disable Anti Spyware set to FALSE"); Get-WriteLog
    #Enable AntiSpyware
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    $registryPath ="HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended"
    If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
    #https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies#smartscreen-settings
    $LogMessage = ("AV Configuratio: New registry edit created at $registryPath"); Get-WriteLog

    New-ItemProperty $registryPath -Name "SmartScreenEnabled" -Value "1" -PropertyType DWORD -Force;
    $LogMessage = ("AV Configuratio: Smart Screen Enabled set to TRUE"); Get-WriteLog
    #Enables Smart Screen for Edge

    New-ItemProperty $registryPath -Name "SmartScreenPuaEnabled" -Value "1" -PropertyType DWORD -Force;
    $LogMessage = ("AV Configuratio: Smart Screen Pua Enabled set to TRUE"); Get-WriteLog    
    #Block potentially unwanted apps

    New-ItemProperty $registryPath -Name "SmartScreenForTrustedDownloadsEnabled" -Value "1" -PropertyType DWORD -Force;
    $LogMessage = ("AV Configuratio: Smart Screen For Trusted Downloads Enabled set to TRUE"); Get-WriteLog 
    #Force checks on downloads from trusted sources

    New-ItemProperty $registryPath -Name "PreventSmartScreenPromptOverride" -Value "1" -PropertyType DWORD -Force;
    $LogMessage = ("AV Configuratio: Prevent Smart Screen Prompt Overrided set to TRUE"); Get-WriteLog 
    #Prevent bypassing Microsoft Defender SmartScreen prompts for sites
    
    New-ItemProperty $registryPath -Name "PreventSmartScreenPromptOverrideForFiles" -Value "1" -PropertyType DWORD -Force;
    $LogMessage = ("AV Configuratio: Prevent Smart Screen Prompt Override For Files to TRUE"); Get-WriteLog
    #Prevent bypassing of Microsoft Defender SmartScreen warnings about downloads

    #------------------------------------------------------------------------------------------------------------------------------------
    #Configuring a update schedule
    #------------------------------------------------------------------------------------------------------------------------------------

    Set-MpPreference -SignatureScheduleDay 0
    $LogMessage = ("AV Configuratio: Check for Virus signatures set to daily"); Get-WriteLog
    #Specifies the day of the week on which to check for definition updates. 0 is every day

    Set-MpPreference -SignatureScheduleTime 10:00:00
    $LogMessage = ("AV Configuratio: Check for Virus signatures at 10:00AM"); Get-WriteLog
    #Specifies the time of day, as the number of minutes after midnight, to check for definition updates. 600 = 10am

    Set-MpPreference -SignatureUpdateInterval 9
    #Specifies the interval, in hours, at which to check for definition updates.

    Set-MpPreference -SignatureUpdateCatchupInterval 1
    #Specifies the number of days after which Windows Defender requires a catch-up definition update.

    #------------------------------------------------------------------------------------------------------------------------------------
    #Configuring Firewall
    #------------------------------------------------------------------------------------------------------------------------------------

    Set-NetFirewallProfile -Enabled True
    $LogMessage = ("AV Configuratio: Firewall Enabled"); Get-WriteLog
    #Turns On the Windows Firewall for all network profiles

    #Set-NetFirewallProfile -Profile Public -Enabled True
    #Enable the public network firewall

    #Set-NetFirewallProfile -Profile Private -Enabled True
    #Enable the private network firewall

}else {
    $LogMessage = ("NO AV CONFIGURATION APPLIED"); Get-WriteLog
}

