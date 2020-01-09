# Script 8 for WIN-EXC-SHP

Write-Host "Configuring sharepoint farm..."

Add-PsSnapin Microsoft.SharePoint.PowerShell | Out-Null
Start-SPAssignment -Global | Out-Null

$password = ConvertTo-SecureString "Admin2019" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ("VANLIEFFERINGE\Administrator",$password)

Write-Host 'Creating database...'
New-SPConfigurationDatabase -DatabaseServer "WIN-SQL-SCCM" -DatabaseName "SHP_conf" -AdministrationContentDatabaseName "SP2016_conf" -Passphrase $password -FarmCredentials $credentials -localserverrole "SingleServerFarm" 

# install features
Write-Host "Installing features..."
Install-SPHelpCollection -All
Initialize-SPResourceSecurity
Install-SPService
Install-SPFeature -AllExistingFeatures
Install-SPApplicationContent
New-SPCentralAdministration -Port 8080 -WindowsAuthProvider "NTLM"
Write-Host "install complete..."

# load next script
& "c:\scripts\WIN-EXC-SHP\9_shp_webapp.ps1"
