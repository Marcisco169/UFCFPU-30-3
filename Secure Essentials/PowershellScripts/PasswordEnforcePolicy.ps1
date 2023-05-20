Import-Module Microsoft.PowerShell.LocalAccounts

function Get-WriteLog{
#This is a function to save to a log file
    $LogTime = (Get-Date -Format "HH:mm:ss.ffff")+ (" - ")
    #Time for log
    $LogTime+ $LogMessage | Out-File -FilePath .\Log_*.txt -Append
    #Add the log time and message to the file
}
#------------------------------------------------------------------------------------------------------------------------------------
#Responsible for finding all users and requring they have a password set
#------------------------------------------------------------------------------------------------------------------------------------
$AllUsers=@((Get-LocalUser).name)
#Array of all users on the system

for( $i = 0; $i -lt $AllUsers.Count; $i++ ){
    net user $AllUsers[$i] /passwordreq:yes}
    $LogMessage = ("User Account Update: $AllUsers[$i] now requires a password set"); Get-WriteLog
    #Loop all users and require them to have a password

#------------------------------------------------------------------------------------------------------------------------------------
#Finding all users and requesting a reset
#------------------------------------------------------------------------------------------------------------------------------------

#~ A function like this is not required for PIN. PINs are optional
#~ If a PIN is not compliant with the policy, the user will be requested to change it next logon automatically

for( $i = 0; $i -lt $AllUsers.Count; $i++ ){
#While i is less than the length of "NoPassword", loop
    Set-LocalUser -Name $AllUsers[$i] -PasswordNeverExpires $false
    $LogMessage = ("User Account Update: $UserAccount must reset their password upon next logon"); Get-WriteLog
}

#------------------------------------------------------------------------------------------------------------------------------------
#Setting the password policy
#------------------------------------------------------------------------------------------------------------------------------------
net accounts /uniquepw:5
$LogMessage = ("Password Policy Update: Password history set to 5"); Get-WriteLog
#Determines the number of unique new passwords that have to be associated with a user account before an old password can be reused.
net accounts /minpwlen:12
$LogMessage = ("Password Policy Update: Minimum password length set to 12"); Get-WriteLog
#A password must be atleast 12 characters long 

#------------------------------------------------------------------------------------------------------------------------------------
#Responsible for setting the PIN requirments
#------------------------------------------------------------------------------------------------------------------------------------
$registryPath ="HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork\PINComplexity"

If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
New-ItemProperty $registryPath -Name "History" -Value "5" -PropertyType DWORD -Force;
$LogMessage = ("Password Policy Update: New registry edit created at $registryPath"); Get-WriteLog
$LogMessage = ("Pin history set to 5"); Get-WriteLog
#A PIN must be atleast 12 characters long 

If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
New-ItemProperty $registryPath -Name "MinimumPINLength" -Value "12" -PropertyType DWORD -Force;
$LogMessage = ("Password Policy Update: New registry edit created at $registryPath"); Get-WriteLog
$LogMessage = ("Minimum Pin length set to 12"); Get-WriteLog
#Determines the number of unique new passwords that have to be associated with a user account before an old PIN can be reused.

#------------------------------------------------------------------------------------------------------------------------------------
#Password lockout
#------------------------------------------------------------------------------------------------------------------------------------
net accounts /lockoutthreshold:6
$LogMessage = ("Password Policy Update: Password lockout threshold set to 6"); Get-WriteLog
net accounts /lockoutwindow:10
$LogMessage = ("Password Policy Update: Lockout window set to 10"); Get-WriteLog
net accounts /Lockoutduration:10
$LogMessage = ("Password Policy Update: Lockout duration set to 10 minutes"); Get-WriteLog

#------------------------------------------------------------------------------------------------------------------------------------
#Responsible for disabiling the PIN functionality
#------------------------------------------------------------------------------------------------------------------------------------
<#
#The PIN needs to be disabled as users cannot be forced to change their PIN upon next logon
#Whichout changing it, a users PIN may not meet CE requirments

$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork";
#Set the desried path
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force;};
#Find the path. If not found, create it

for( $i = 0; $i -lt $PolicyName.Count; $i++ ){
#While i is less than the length of "PolicyName", loop
    New-ItemProperty -Path $registryPath -Name "Enabled"  -Value "0" -PropertyType DWORD -Force;
    #create a new item under the path
}
#>


#------------------------------------------------------------------------------------------------------------------------------------
#Finding all and disable if they have not logged in for a while
#------------------------------------------------------------------------------------------------------------------------------------
$AllUsers=@((Get-LocalUser).name)
$AllUsersLogin=@((Get-LocalUser).LastLogon)
$Today=(Get-Date)

for( $i = 0; $i -lt $AllUsers.Count; $i++ ){
#While i is less than the length of "AllUsers", loop
    if ($AllUsersLogin[$i] -gt $null){
    #If last logon is null, they have never logged in
        $ToalDays=($Today - $AllUsersLogin[1]).TotalDays
        #Subtract last login from today and get the total day since last login

        if ($ToalDays -gt 30){
        #If they logged in more than 30 days ago, then
            Disable-LocalUser -Name $AllUsers[$i]
            #Disable user account
            $LogMessage = "User Account Update: $AllUsers[$i] has been disabled. They logged in $ToalDays ago"; Get-WriteLog
        }
    }else{
        $LogMessage = "No inactive accounts found"; Get-WriteLog
    }
}




