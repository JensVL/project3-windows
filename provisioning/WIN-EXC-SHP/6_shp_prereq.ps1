# Script 6 for WIN-EXC-SHP

$iso = "c:\scripts\WIN-EXC-SHP\officeserver.img"

Write-Host "Installing Sharepoint prereqs..."

Write-Host "checking or downloading iso..."
if (!(Test-Path("$iso"))) {
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/0/0/4/004EE264-7043-45BF-99E3-3F74ECAE13E5/officeserver.img","$iso")
}
# mount exchange iso
$isodrive = (Get-DiskImage -ImagePath $iso | Get-Volume)
if (!($isodrive)) {
    Write-Host 'Mounting iso...'
    Mount-DiskImage -ImagePath $iso
} else {
    Write-Host 'Already mounted...'
}

# set location on iso
$isodrive = (Get-DiskImage -ImagePath $iso | Get-Volume).DriveLetter
Set-Location "${isodrive}:"

# install prereqs
Write-Host 'Installing prereqs...'
Start-Process prerequisiteinstaller.exe /unattended -wait
Import-Module Servermanager
Install-WindowsFeature Net-Framework-Core, NET-HTTP-Activation, NET-Non-HTTP-Activ, NET-WCF-HTTP-Activation45, Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-App-Dev, Web-Asp-Net, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Http-Tracing, Web-Security, Web-Basic-Auth, Web-Filtering, Web-Digest-Auth, Web-Performance, Web-Stat-Compression, Web-Dyn-Compression, Web-Mgmt-Tools, Web-Mgmt-Console, Web-Mgmt-Compat, Web-Metabase, Web-Lgcy-Scripting, Windows-Identity-Foundation, Server-Media-Foundation, Xps-Viewer, BITS-IIS-Ext, WinRM-IIS-Ext, Web-Scripting-Tools, Web-WMI, Web-IP-Security, Web-url-Auth, Web-Cert-Auth, Web-Client-Auth
Install-WindowsFeature Web-Server -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature Was -IncludeAllSubFeature

#load next script
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name ResumeScript -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe -executionpolicy bypass -file c:\scripts\WIN-EXC-SHP\7_shp_setup.ps1"

Restart-Computer
