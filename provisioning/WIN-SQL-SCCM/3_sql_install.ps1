# Script 1 for WIN-SQL-SCCM

Write-Host "Installing SQL Server..."

# Download SQL Server
$downloadpath = 'C:\SetupMedia'

Write-Host "Verifying downloadpath..."
if($downloadpath.EndsWith("\")){
    $computerName.Remove($computerName.LastIndexOf("\"))
}

if(!(Test-Path $downloadpath)){
    mkdir $downloadpath
}

Write-Host 'Downloading SQL installer...'
(New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?linkid=853016", "$downloadpath\sqlinstaller.exe")

Write-Host 'Starting SQL installer...'
Start-Process -FilePath "$downloadpath\sqlinstaller.exe" -ArgumentList "/action=download /quiet /enu /MediaPath=$downloadpath" -Wait -WindowStyle hidden

Write-Host 'Extracting SQL Server files...'
Start-Process -FilePath $downloadpath\SQLServer2017-DEV-x64-ENU.exe -WorkingDirectory $downloadpath /q -wait

# Install SQL Server
$sqlusername = 'VANLIEFFERINGE\Administrator'
$sqlpassword = 'Admin2019'

Write-Host "Installing SQL Server..."
$secure_pw = ConvertTo-SecureString $sqlpassword -AsPlainText -Force
$sccm_pw = [System.Runtime.Interopservices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure_pw))
set-location "$downloadpath\SQLServer2017-DEV-x64-ENU"
.\SETUP.exe  `
/Q  `
/ACTION=Install `
/IACCEPTSQLSERVERLICENSETERMS `
/FEATURES="SQLENGINE,FULLTEXT" `
/INSTANCENAME="MSSQLSERVER" `
/INSTANCEID="MSSQLSERVER" `
/INSTANCEDIR="C:\Program Files\Microsoft SQL Server" `
/SQLCOLLATION=SQL_Latin1_General_CP1_CI_AS `
/SQLSVCACCOUNT="$sqlusername" `
/SQLSVCPASSWORD="$sccm_pw" `
/SQLTELSVCACCT="NT Service\SQLTELEMETRY" `
/SQLTELSVCSTARTUPTYPE="Automatic" `
/AGTSVCACCOUNT="$sqlusername" `
/AGTSVCPASSWORD="$sccm_pw" `
/AGTSVCSTARTUPTYPE="Automatic" `
/FTSVCACCOUNT="$sqlusername" `
/FTSVCPASSWORD="$sccm_pw" `
/SQLSYSADMINACCOUNTS="$sqlusername" `
/SAPWD="$sccm_pw" `
/SECURITYMODE="SQL" `
/INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server" `
/INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server" `
/TCPENABLED="1" `
/NPENABLED="1"

# Add local users to admin
Write-Host 'Adding local users to administrator group...'
Add-LocalGroupMember -Group "Administrators" -Member "VANLIEFFERINGE\Administrator"
Add-LocalGroupMember -Group "Administrators" -Member "VANLIEFFERINGE\WIN-SQL-SCCM$"

# Misc sql settings like firewall etc
Write-Host "Importing SQL module..."
Import-Module -name 'C:\Program Files (x86)\Microsoft SQL Server\140\Tools\PowerShell\Modules\SQLPS'

Write-Host "Restarting SQL Instance..."
Restart-Service -Force "MSSQLSERVER" > $null

Write-Host "Setting firewall rule..."
New-NetFirewallRule -DisplayName "Allow inbound sqlserver" -Direction Inbound -LocalPort 1443 -Protocol TCP -Action Allow > $null

# Download SSMS
Write-Host 'Downloading SSMS installer...'
(New-Object System.Net.WebClient).DownloadFile("https://aka.ms/ssmsfullsetup", "$downloadpath\SSMS-Setup-ENU.exe")

Write-Host "Installing SSMS..."
Start-Process -Filepath "$downloadpath\SSMS-Setup-ENU.exe" -ArgumentList -silent -Wait

# Enable TCP/IP
$wmi = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer').  

$Tcp = $wmi.GetSmoObject("ManagedComputer[@Name='WIN-SQL-SCCM']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']")  
$Tcp.IsEnabled = $true  
$Tcp.Alter()  

#Set up scripts to run on next reboot
Write-Host 'Copying scripts...'
$scripts = "C:\scripts"

# Check paths again
if(!(Test-Path $scripts)){
    mkdir $scripts
}

Copy-Item -r "C:\vagrant\provisioning\WIN-SQL-SCCM\" "$scripts" -Force

# Set up auto logon
Write-Host 'Configuring auto logon as domain admin...'
$secure = ConvertTo-SecureString $sqlpassword -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($sqlusername, $secure)

$pw = $credentials.GetNetworkCredential().Password

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $sqlusername
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $pw
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name ForceAutoLogon -Value 1

# load in next script
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name ResumeScript -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe -executionpolicy bypass -file $scripts\WIN-SQL-SCCM\4_admin_perms.ps1"
