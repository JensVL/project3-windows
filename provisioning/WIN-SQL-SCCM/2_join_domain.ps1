# Script 2 for WIN-SQL-SCCM

Write-Host "Joining domain..."

$password = "Admin2019" | ConvertTo-SecureString -AsPlainText -Force

$credentials = New-Object System.Management.Automation.PsCredential("VANLIEFFERINGE\Administrator",$password) 
Add-computer -DomainName "vanliefferinge.periode1" -DomainCredential $credentials -Verbose

Write-Host "Complete..."