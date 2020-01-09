# Script 2 for WIN-DC1

Write-Host "Starting DC 1 configuration..."

# set timezone
Set-Culture -CultureInfo 'eng-BE'
Set-Timezone -Name "Romance Standard Time"

# add a local admin user
Write-Host "Adding local Admin..."
$password = "Admin2019" | ConvertTo-SecureString -AsPlainText -Force
Set-LocalUser -Name Administrator -AccountNeverExpires -Password $password -PasswordNeverExpires:$true -UserMayChangePassword:$true

#install AD DS features
Write-Host "Installing AD features..."
Install-WindowsFeature AD-Domain-Services
Install-WindowsFeature RSAT-AD-AdminCenter
Install-WindowsFeature RSAT-ADDS-Tools

Write-Host "Adding a forest..."

# add a forest
Import-Module ADDSDeployment
Install-ADDSForest -InstallDns -CreateDnsDelegation:$False -ForestMode 7 -DomainMode 7 -DomainName "vanliefferinge.periode1" -SafeModeAdministratorPassword $password -NoRebootOnCompletion -Force

# try to find the domain every 10 seconds until it is installed
#Write-Host "Waiting for domain..."

#while ($true) {
#    try {
#        Get-ADDomain | Out-Null
#        break
#    } catch {
#        Write-Host "Still waiting..."
#        Start-Sleep -Seconds 10
#    }
#}

#Import-Module ActiveDirectory

#Write-Host "Disable unused accounts..."
#$enabledaccounts = @("vagrant","Administrator")
#Get-ADUser -Filter {Enabled -eq $true} | Where-Object {$enabledaccounts -notcontains $_.Name} | Disable-ADAccount

#Set-ADAccountPassword -Identity "CN=Administrator,CN=users,Get-ADDomain.DistinguishedName" -Reset -NewPassword $password
#Set-ADUser -Identity "CN=Administrator,CN=users,Get-ADDomain.DistinguishedName" -PasswordNeverExpires $true

#Write-Host "Add vagrant account..."
#Add-ADGroupMember -Identity 'Domain Admins' -Members "CN=vagrant,CN=users,Get-ADDomain.DistinguishedName"
#Add-ADGroupMember -Identity 'Enterprise Admins' -Members "CN=vagrant,CN=users,Get-ADDomain.DistinguishedNameh"

#add a OU and account
#New-ADOrganizationalUnit -Name "IT" -Description "IT OU"
#New-ADGroup -Name "IT" -DisplayName "IT" -Path "OU=IT,DC=vanliefferinge,DC=periode1" -GroupCategory Security -GroupScope Global
#New-AdUser -Name "Jens" -Surname "Van Liefferinge" -SamAccountName "JensVL" -Department "IT" -Description "JensVL Account" -DisplayName "JensVL" -GivenName "Jens" -State "Brussels" -City "Brussels" -PostalCode "1000" -EmailAddress "jensvl@vanliefferinge.periode1" -Office "D1" -EmployeeID 10 -HomePhone "0499999999" -Initials "JVL" -Path "OU=IT,DC=vanliefferinge,DC=periode1" -AccountPassword $password

#configure user and managers into group
#Add-ADGroupMember -Identity "CN=IT,OU=IT,DC=vanliefferinge,DC=periode1" -Members "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"
#Set-ADGroup -Identity "CN=IT,OU=IT,DC=vanliefferinge,DC=periode1" -ManagedBy "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"
#Set-ADOrganizationalUnit -Identity "OU=IT,DC=vanliefferinge,DC=periode1" -ManagedBy "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"

#enable the account
#Enable-ADAccount -Identity "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"

Write-Host "Complete..."
