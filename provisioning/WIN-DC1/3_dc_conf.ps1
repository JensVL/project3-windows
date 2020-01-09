# Extra script because server needs to reboot

Write-Host "Waiting for domain..."

while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Write-Host "Still waiting..."
        Start-Sleep -Seconds 10
    }
}

Import-Module ActiveDirectory

Write-Host "Disabling unused accounts..."

$enabledaccounts = @("vagrant","Administrator")
$password = "Admin2019" | ConvertTo-SecureString -AsPlainText -Force
$domad = Get-ADDomain
$domname = $domad.DistinguishedName
$path = "CN=Users,$domname"

Get-ADUser -Filter {Enabled -eq $true} | Where-Object {$enabledaccounts -notcontains $_.Name} | Disable-ADAccount

Set-ADAccountPassword -Identity "CN=Administrator,$path" -Reset -NewPassword $password
Set-ADUser -Identity "CN=Administrator,$path" -PasswordNeverExpires $true

Write-Host "Adding vagrant account..."
Add-ADGroupMember -Identity 'Domain Admins' -Members "CN=vagrant,$path"
Add-ADGroupMember -Identity 'Enterprise Admins' -Members "CN=vagrant,$path"

#add a OU and account
Write-Host "Setting up Org Units..."

New-ADOrganizationalUnit -Name "IT" -Description "IT OU"
New-ADGroup -Name "IT" -DisplayName "IT" -Path "OU=IT,DC=vanliefferinge,DC=periode1" -GroupCategory Security -GroupScope Global
New-AdUser -Name "Jens" -Surname "Van Liefferinge" -SamAccountName "JensVL" -Department "IT" -Description "JensVL Account" -DisplayName "JensVL" -GivenName "Jens" -State "Brussels" -City "Brussels" -PostalCode "1000" -EmailAddress "jensvl@vanliefferinge.periode1" -Office "D1" -EmployeeID 10 -HomePhone "0499999999" -Initials "JVL" -Path "OU=IT,DC=vanliefferinge,DC=periode1" -AccountPassword $password

#configure user and managers into group
Add-ADGroupMember -Identity "CN=IT,OU=IT,DC=vanliefferinge,DC=periode1" -Members "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"
Set-ADGroup -Identity "CN=IT,OU=IT,DC=vanliefferinge,DC=periode1" -ManagedBy "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"
Set-ADOrganizationalUnit -Identity "OU=IT,DC=vanliefferinge,DC=periode1" -ManagedBy "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"

#enable the account
Enable-ADAccount -Identity "CN=Jens,OU=IT,DC=vanliefferinge,DC=periode1"