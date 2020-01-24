# Script 5 for WIN-SQL-SCCM

Write-Host "Starting SCCM installation..."

$downloadpath = 'C:\SetupMedia'

# Verify downloadpath
Write-Host 'Verifying downloadpath...'
if($downloadpath.EndsWith("\")){
    $computerName.Remove($computerName.LastIndexOf("\"))
}
if(!(Test-Path $downloadpath)){
    mkdir $downloadpath
}

# Check for elevated shell
Write-Host "Checking for elevation..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "You need to run this script from an elevated PowerShell prompt..."
    Break
}

# Extend AD schema using separate script
Write-Host 'Loading script...'
Invoke-Command -FilePath "C:\scripts\WIN-SQL-SCCM\prep_ad_for_sccm.ps1" -ComputerName "WIN-DC1"

Write-Host 'Extending AD schema on WIN-DC1...'
Copy-Item "C:\scripts\WIN-SQL-SCCM\ExtendADschema" -Destination "C:\" -Recurse
Start-Process "C:\ExtendADschema\extadsch.exe" -wait

# Downloading prereqs
Write-Host 'Downloading ADK installer...'
(New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?linkid=2086042", "$downloadpath\adksetup.exe")

Write-Host 'Downloading WinPE addon installer...'
(New-Object System.Net.WebClient).DownloadFile("https://go.microsoft.com/fwlink/?linkid=2087112", "$downloadpath\adkwinpesetup.exe")

Write-Host 'Downloading MDT installer...'
(New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi", "$downloadpath\MicrosoftDeploymentToolkit_X64.msi")

Write-Host 'Downloading Adobe Reader installer...'
(New-Object System.Net.WebClient).DownloadFile("ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/1500720033/AcroRdrDC1500720033_en_US.msi", "$downloadpath\AcroRdrDC1500720033_en_US.msi")

if (!(Test-Path -path "C:\scripts\WIN-SQL-SCCM\win10\Windows10_1809.iso")) {
  Write-Host "Downloading win10 iso..."
  (New-Object System.Net.WebClient).DownloadFile("https://archive.org/download/Win10ConsumerEditionsv1809x86x64/en_windows_10_consumer_editions_version_1809_updated_dec_2018_x64_dvd_d7d23ac9.iso", "C:\scripts\WIN-SQL-SCCM\win10\Windows10_1809.iso")
} else {
  Write-Host "win10 iso present..."
}


# Install prereqs

# Validate installers are present
if (!(Test-Path -path "$downloadpath\adksetup.exe")) {
    Write-Host 'ADK installer missing...'
    Break
}
if (!(Test-Path -path "$downloadpath\adkwinpesetup.exe")) {
    Write-Host 'WinPE installer missing...'
    Break
}
if (!(Test-Path -path "$downloadpath\MicrosoftDeploymentToolkit_X64.msi")) {
    Write-Host 'MDT installer missing...'
    Break
}

# Install ADK
Write-Host "Installing ADK..."
Start-Process -FilePath "$downloadpath\adksetup.exe" -ArgumentList "/Features OptionId.DeploymentTools OptionId.ImagingAndConfigurationDesigner OptionId.ICDConfigurationDesigner OptionId.UserStateMigrationTool /norestart /quiet /ceip off" -NoNewWindow -Wait

if ($?) {
  Write-Host "Installation ADK completed..."
} else {
  Write-Host "Installation ADK failed..."
}

# Install WinPE
Write-Host "Installing WinPE..."
Start-Process -FilePath "$downloadpath\adkwinpesetup.exe" -ArgumentList "/Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off" -NoNewWindow -Wait

if ($?) {
  Write-Host "Installation WinPE completed..."
} else {
  Write-Host "Installation WinPE failed..."
}

# Install MDT
Write-Host "Installing MDT..."
Start-Process "$downloadpath\MicrosoftDeploymentToolkit_X64.msi" /quiet -wait

if ($?) {
  Write-Host "Installation Windows MDT completed..."
} else {
  Write-Host "Installation Windows MDT failed..."
}

# Install WDS
Write-Host 'Installing WDS...'
Import-Module ServerManager
Install-WindowsFeature -Name WDS -IncludeManagementTools

# Install IIS, BITS and RDS extras
Write-Host "Installing IIS, BITS and RDC..."
Install-WindowsFeature Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,Web-Http-Errors,Web-Http-Redirect,Web-Net-Ext,Web-ISAPI-Ext,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-Windows-Auth,Web-Filtering,Web-Stat-Compression,Web-Mgmt-Tools,Web-Mgmt-Compat,Web-Metabase,Web-WMI,BITS,RDC

# Install and configure WSUS for SQL
Write-Host "Installing WSUS..."
Install-WindowsFeature -Name UpdateServices-DB, UpdateServices-Services -IncludeManagementTools
New-Item -Path "C:\" -ItemType Directory -Name "WSUS"

# Link WSUS to SQL
Write-Host "Configuring WSUS for SQL Server"
Set-Location -Path "C:\Program Files\Update Services\Tools"
.\wsusutil.exe postinstall SQL_INSTANCE_NAME="WIN-SQL-SCCM" CONTENT_DIR=C:\WSUS

# Configure firewall to allow traffic
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)" -confirm:$false
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (NB-Name-In)" -confirm:$false
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (NB-Session-In)" -confirm:$false 
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (SMB-In)" -confirm:$false

netsh advfirewall firewall add rule name="SCCM Management Point" dir=in action=allow profile=domain localport="7080,7443,10123" protocol=TCP

New-NetFirewallRule -Group SCCM -DisplayName "SCCM - File Share - TCP - 445" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow -Profile Domain | Out-Null
New-NetFirewallRule -Group SCCM -DisplayName "SCCM - File Share - UDP - 137-138" -Direction Inbound -Protocol UDP -LocalPort "137-138" -Action Allow -Profile Domain | Out-Null
New-NetFirewallRule -Group SCCM -DisplayName "SCCM - RPC - TCP - 135" -Direction Inbound -Protocol TCP -LocalPort 135 -Action Allow -Profile Domain | Out-Null
New-NetFirewallRule -Group SCCM -DisplayName "SCCM - NetBIOS - TCP - 139" -Direction Inbound -Protocol TCP -LocalPort 139 -Action Allow -Profile Domain | Out-Null
New-NetFirewallRule -Group SCCM -DisplayName "SCCM - Dynamic Ports - TCP - 49154-49157" -Direction Inbound -Protocol TCP -LocalPort "49154-49157" -Action Allow -Profile Domain | Out-Null
New-NetFirewallRule -Group SCCM -DisplayName "SCCM - UDP - 5355" -Direction Inbound -Protocol UDP -LocalPort "5355" -Action Allow -Profile Domain | Out-Null

Get-Service RemoteRegistry | Set-Service -StartupType Automatic -PassThru | Start-Service

# Install SCCM

# Download installer
Write-Host 'Downloading SCCM installer...'
(New-Object System.Net.WebClient).DownloadFile("http://download.microsoft.com/download/1/B/C/1BCADBD7-47F6-40BB-8B1F-0B2D9B51B289/SC_Configmgr_SCEP_1902.exe", "$downloadpath\SC_Configmgr_SCEP_1902.exe")

Write-Host 'Extracting SCCM files...'
Move-Item "$downloadpath\SC_Configmgr_SCEP_1902.exe" "$downloadpath\SC_Configmgr_SCEP_1902.zip"
Expand-Archive -Path "$downloadpath\SC_Configmgr_SCEP_1902.zip" -DestinationPath "$downloadpath\SC_Configmgr_SCEP_1902"

Write-Host 'Downloading prereqs...'
Start-Process "$downloadpath\SC_Configmgr_SCEP_1902\SMSSETUP\BIN\x64\setupdl.exe" -ArgumentList "$downloadpath\prereqs" -wait

Write-Host 'Running prereq check...'
Start-Process "$downloadpath\SC_Configmgr_SCEP_1902\SMSSETUP\BIN\x64\prereqchk.exe" -ArgumentList "/NOUI /PRI /SQL WIN-SQL-SCCM.vanliefferinge.periode1 /SDK WIN-SQL-SCCM.vanliefferinge.periode1 /MP WIN-SQL-SCCM.vanliefferinge.periode1 /DP WIN-SQL-SCCM.vanliefferinge.periode1" -wait

Write-Host 'Installing SCCM...'
Start-Process "$downloadpath\SC_Configmgr_SCEP_1902\SMSSETUP\BIN\x64\setup.exe" -ArgumentList "/script C:\scripts\WIN-SQL-SCCM\sccm_install_config.ini" -wait

# Integrate MDT with SCCM
Write-Host "Integrating MDT with SCCM..."

$MDT = "C:\Program Files\Microsoft Deployment Toolkit"
$SCCM = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole"
$MOF = "$SCCM\Bin\Microsoft.BDD.CM12Actions.mof"

Copy-Item "$MDT\Bin\Microsoft.BDD.CM12Actions.dll" "$SCCM\Bin\Microsoft.BDD.CM12Actions.dll"
Copy-Item "$MDT\Bin\Microsoft.BDD.Workbench.dll" "$SCCM\Bin\Microsoft.BDD.Workbench.dll"
Copy-Item "$MDT\Bin\Microsoft.BDD.ConfigManager.dll" "$SCCM\Bin\Microsoft.BDD.ConfigManager.dll"
Copy-Item "$MDT\Bin\Microsoft.BDD.CM12Wizards.dll" "$SCCM\Bin\Microsoft.BDD.CM12Wizards.dll"
Copy-Item "$MDT\Bin\Microsoft.BDD.PSSnapIn.dll" "$SCCM\Bin\Microsoft.BDD.PSSnapIn.dll"
Copy-Item "$MDT\Bin\Microsoft.BDD.Core.dll" "$SCCM\Bin\Microsoft.BDD.Core.dll"
Copy-Item "$MDT\SCCM\Microsoft.BDD.CM12Actions.mof" $MOF
Copy-Item "$MDT\Templates\CM12Extensions\*" "$SCCM\XmlStorage\Extensions\" -Force -Recurse
(Get-Content $MOF).Replace('%SMSSERVER%', "Van Liefferinge Site").Replace('%SMSSITECODE%', "JVL") | Set-Content $MOF
Get-Content $MOF
& "C:\Windows\System32\wbem\mofcomp.exe" "$SCCM\Bin\Microsoft.BDD.CM12Actions.mof"

# Configure SCCM

# import SCCM commands
Set-Location -Path "$SCCM\bin"
Import-Module .\ConfigurationManager.psd1
New-PSDrive -Name "JVL" -PsProvider "AdminUI.PS.Provider\CMSite" -Root "WIN-SQL-SCCM.vanliefferinge.periode1" -Description "Site drive for JVL"

Start-Sleep -s 30
Set-Location -Path JVL:

# Create boundary group
Write-Host "Creating boundaries and boundary groups..."
New-CMBoundary -Type ADSite -DisplayName "Active Directory Site" -Value "Default-First-Site-Name"
New-CMBoundaryGroup -Name "ADsite"
Set-CMBoundaryGroup -Name "ADsite" -AddSiteSystemServerName "WIN-SQL-SCCM.vanliefferinge.periode1" -DefaultSiteCode "JVL"
Add-CMBoundaryToGroup -BoundaryGroupName "ADSite" -BoundaryName "Active Directory Site"
Write-Host "boundaries creation complete..."

### Configure client settings and network access account
Set-CMClientSettingComputerAgent -BrandingTitle "JVL" -DefaultSetting

Write-Host "Configuring Network Access account..."
$password = ConvertTo-SecureString 'Admin2019' -AsPlainText -Force
New-CMAccount -UserName "VANLIEFFERINGE\Administrator" -Password $password -SiteCode "JVL"
Set-CMSoftwareDistributionComponent -SiteCode "JVL" -AddNetworkAccessAccountName "VANLIEFFERINGE\Administrator"

# Turn on discovery method to scan for new devices etc
Write-Host 'Turning on discovery methods...'
Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery -SiteCode "JVL" -Enabled $true
Set-CMDiscoveryMethod -NetworkDiscovery -SiteCode "JVL" -Enabled $true -NetworkDiscoveryType ToplogyAndClient
Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery -SiteCode "JVL" -Enabled $true -ActiveDirectoryContainer "LDAP://DC=vanliefferinge,DC=periode1"
Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery -SiteCode "JVL" -Enabled $true -ActiveDirectoryContainer "LDAP://DC=vanliefferinge,DC=periode1"

$scope = New-CMADGroupDiscoveryScope -LDAPlocation "LDAP://DC=vanliefferinge,DC=periode1" -Name "ADdiscoveryScope" -RecursiveSearch $true
Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery -SiteCode "JVL" -Enabled $true -AddGroupDiscoveryScope $scope

# Configure PXE boot
Write-Host "Configuring PXE boot..."
Set-CMDistributionPoint -SiteSystemServerName "WIN-SQL-SCCM.vanliefferinge.periode1" -enablePXE $true -AllowPxeResponse $true -EnableUnknownComputerSupport $true -RespondToAllNetwork
Write-Host "PXE boot configured..."


# Create win10 ref image
Write-Host "Copying win10 iso..."
Copy-Item "C:\scripts\WIN-SQL-SCCM\win10" -Destination "C:\" -Recurse -Verbose

Mount-DiskImage -ImagePath "C:\scripts\WIN-SQL-SCCM\win10\Windows10_1809.iso"
Write-Host "Copy and mount of iso complete..."
Write-Host "Creating deployment share..."

# Import MDT commamds
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
New-Item -type "Directory" -Path "C:\DeploymentShare"

# Create share
([wmiclass]"win32_share").Create("C:\DeploymentShare","DeploymentShare",0)
New-PSDrive -Name "DS001" -PSProvider "MicrosoftDeploymentToolkit\MDTProvider" -Root "C:\DeploymentShare" -Description "Deployment Share for Windows 10" -Verbose

# 10.3) Import win10 img into share
Import-MDTOperatingSystem -SourcePath "D:\" -Path "DS001:\Operating Systems" -DestinationFolder "Win10Consumers1809" -verbose

# add software update role
Set-Location JVL:
Write-Host "Adding software update point..."
Add-CMSoftwareUpdatePoint -SiteCode "JVL" -SiteSystemServerName "WIN-SQL-SCCM.vanliefferinge.periode1" -ClientConnectionType "Intranet"

# link wsus and sccm
Set-CMSoftwareUpdatePointComponent -SynchronizeAction "SynchronizeFromMicrosoftUpdate" -ReportingEvent "DoNotCreateWsusReportingEvents" -RemoveUpdateClassification "Service Packs","Upgrades","Update Rollups","Tools","Driver sets","Applications","Drivers","Feature Packs","Definition Updates","Updates" -AddUpdateClassification "Updates", "Driver sets" -SiteCode "JVL" -verbose

# only set english updates
Write-Host "Enabling ENG for updates..."

$WSUSserver = Get-WSUSserver
$WSUSconfig = $WSUSserver.GetConfiguration()
$WSUSconfig.AllUpdateLanguagesEnabled = $false
$WSUSconfig.SetEnabledUpdateLanguages("en")
$WSUSconfig.Save()

#Sync software updates with update servers
$beforeSync = Get-Date

Restart-Service -Name sms_executive
Sync-CMSoftwareUpdate -FullSync $true

Start-Sleep -Seconds 300
Write-Host "Starting sync of updates..."
$syncStatus = Get-CMSoftwareUpdateSyncStatus
Sync-CMSoftwareUpdate -FullSync $true

$maxSeconds = (60*70)
$endWait = $beforeSync.AddSeconds($maxSeconds)

Write-Host "Waiting on sync..."
while ($now -lt $endWait) {
    $now = Get-Date
    $syncStatus = Get-CMSoftwareUpdateSyncStatus
    if ($null -eq $syncStatus.LastSuccessfulSyncTime -or $syncStatus.LastSuccessfulSyncTime -lt $beforeSync) {
        continue
    } else {
        Write-Host "Sync complete..."
        break
    }
}

# add win10
Set-CMSoftwareUpdatePointComponent -SiteCode "JVL" -AddProduct "Windows 10, version 1809 and later, Upgrade & Servicing Drivers"
