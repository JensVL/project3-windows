# Script 6 for WIN-DC1

Write-Host "Starting DHCP configuration..."

Install-WindowsFeature DHCP -IncludeManagementTools

Add-DhcpServerInDC -DnsName "WIN-DC1.vanliefferinge.periode1" -IpAddress 192.168.100.10

# add a scope and settings
Write-Host "Adding scope..."
Add-DhcpServerV4Scope -Name 'DHCP Scope' -StartRange 192.168.100.150 -EndRange 192.168.100.200 -SubnetMask 255.255.255.0 -State Active

Write-Host "Configuring scope..."
Set-DhcpServerv4OptionValue -ScopeId 192.168.100.150 -OptionId 066 -Value "WIN-SQL-SCCM.vanliefferinge.periode1"
Set-DhcpServerv4OptionValue -ScopeId 192.168.100.150 -OptionId 067 -Value "\smsboot\x64\wdsnbp.com"

Set-DhcpServerv4Scope -ScopeId 192.168.100.150 -LeaseDuration 7.00:00:00
Set-DhcpServerV4OptionValue -ScopeId 192.168.100.150 -DnsDomain "vanliefferinge.periode1" -DnsServer 192.168.100.10,192.168.100.20 -Router 192.168.100.10

Restart-service -Name dhcpserver

# verify settings
Get-DhcpServerv4Scope
Get-DhcpServerInDC

Write-Host "Enabling specific sharing services..."

Set-Service -Name "FDResPub" -StartupType "Automatic"
Start-Service -DisplayName "Function Discovery Resource Publication" 

Set-Service -Name "Dnscache" -StartupType "Automatic" 2> $null
Start-Service -DisplayName "DNS Client" 

Set-Service -Name "SSDPSRV" -StartupType "Automatic"
Start-Service -DisplayName "SSDP Discovery" 

Set-Service -Name "upnphost" -StartupType "Automatic"
Start-Service -DisplayName "UPnP Device Host" 

# Allow services through firewall
# Set action to allow
Write-Host "Allow services trough firewall..."
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Set-NetFirewallRule -Action Allow
# Enabling the rule
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Enable-NetFirewallRule

Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Set-NetFirewallRule -Action Allow 
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule

# Turn on network discovery
netsh advfirewall firewall set rule group="Network Discovery"ù new enable=Yes

Write-Host "Complete..."
