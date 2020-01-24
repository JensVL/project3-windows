# Script 2 for WIN-DC2

Write-Host "Starting DC 2 configuration..."

. "c:\vagrant\provisioning\forest.ps1"


# set timezone
Set-Culture -CultureInfo 'eng-BE'
Set-Timezone -Name "Romance Standard Time"

# add a local admin user
Write-Host "Adding local Admin..."
$password = "Admin2019" | ConvertTo-SecureString -AsPlainText -Force
$localpw = "Admin1234" | ConvertTo-SecureString -AsPlainText -Force
Set-LocalUser -Name Administrator -AccountNeverExpires -Password $localpw -PasswordNeverExpires:$true -UserMayChangePassword:$true

# add ADDS features
Write-Host "Installing AD features..."
Install-WindowsFeature AD-Domain-Services
Install-WindowsFeature RSAT-AD-AdminCenter
Install-WindowsFeature RSAT-ADDS-Tools

# Add to existing forest
Write-Host " Adding to forest..."

Import-Module ADDSDeployment
$credentials = New-Object System.Management.Automation.PSCredential("VANLIEFFERINGE\Administrator",$password)
install-ADDSDomainController -DomainName "vanliefferinge.periode1" -ReplicationSourceDC "WIN-DC1.vanliefferinge.periode1" -credential $credentials -InstallDns -createDNSDelegation:$false -NoRebootOnCompletion -SafeModeAdministratorPassword $password -Force

# above gives error

# trying with function

$domain = 'vanliefferinge.periode1'
$dc1 = 'WIN-DC1'

#forest $domain $password $dc1

Write-Host " Complete..."

