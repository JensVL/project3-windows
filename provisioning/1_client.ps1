# Script 1 for WIN-CLT

Write-Host "Joining domain..."

$password = "Admin2019" | ConvertTo-SecureString -AsPlainText -Force

$credentials = New-Object System.Management.Automation.PsCredential("VANLIEFFERINGE\JensVL",$password) 
Add-computer -DomainName "vanliefferinge.periode1" -DomainCredential $credentials -Verbose

Write-Host "Complete..."