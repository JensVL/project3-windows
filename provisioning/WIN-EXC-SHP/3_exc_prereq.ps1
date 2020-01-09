# Script 3 for WIN-EXC-SHP

# install prereq features
Write-Host "Installing Exchange prerequisites..."
 
Install-WindowsFeature Server-Media-Foundation
Install-WindowsFeature RSAT-ADDS
Install-WindowsFeature RSAT-Clustering-CmdInterface, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS

Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Install complete..."

# autoconfirm chocolatey
choco feature enable -n=allowGlobalConfirmation

# install additional prereqs
Write-Host 'Installing .NET ...'
choco install dotnet4.7.2 -y

Write-Host 'Installing Visual C++ redistributables...'
choco install vcredist2013 -y

Write-Host 'Installing UCMA...'
choco install ucma4 -y

# copy scripts for easy access
Write-Host 'Copying scripts...'
$scripts = "C:\scripts"

# check paths
if(!(Test-Path $scripts)){
    mkdir $scripts
}

Copy-Item -r "c:\vagrant\provisioning\WIN-EXC-SHP\" "$scripts" -Force

# Set up auto logon
Write-Host 'Configuring auto logon as domain admin...'

$password='Admin2019'
$user='VANLIEFFERINGE\Administrator'

$secure = ConvertTo-SecureString $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($user, $secure)

$pw = $credentials.GetNetworkCredential().Password

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $user
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $pw
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name ForceAutoLogon -Value 1

Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name ResumeScript -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe -executionpolicy bypass -file $scripts\WIN-EXC-SHP\4_exc_prep_ad.ps1"
