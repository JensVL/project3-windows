# Script 1 for WIN-DC2

Write-Host "Setting up adapters..."

# Rename adapters to WAN and LAN for clarity
$adaptercount = (Get-NetAdapter | Measure-Object).count
if ($adaptercount -eq 1) {
        (Get-NetAdapter -Name "Ethernet" 2> $null) | Rename-NetAdapter -NewName "WAN"
    }

elseif ($adaptercount -eq 2) {
    (Get-NetAdapter -Name "Ethernet" 2> $null) | Rename-NetAdapter -NewName "WAN"
    (Get-NetAdapter -Name "Ethernet 2" 2> $null) | Rename-NetAdapter -NewName "LAN"
}

# Clear potential static settings and default gateway
Set-NetIPInterface -InterfaceAlias "LAN" -Dhcp Enabled 2> $null
Get-NetIPAddress -InterfaceAlias "LAN" | Remove-NetRoute -Confirm:$false 2> $null

$dns1 = '192.168.100.10'
$dns2 = '192.168.100.20'

# Set the new IP settings + DNS

Write-Host "Setting up new IP settings..."

New-NetIPAddress -InterfaceAlias "LAN" -IPAddress $dns2 -PrefixLength 24 -DefaultGateway $dns1 -AddressFamily IPv4 > $null

Set-DnsClientServerAddress -InterfaceAlias "LAN" -ServerAddresses($dns1,$dns2)
Set-DnsClientServerAddress -InterfaceAlias "WAN" -ResetServerAddresses

# Enable domain sharing services
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
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Set-NetFirewallRule -Action Allow
# Enabling the rule
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Enable-NetFirewallRule

Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Set-NetFirewallRule -Action Allow 
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule

# Turn on network discovery
netsh advfirewall firewall set rule group="Network discovery" new enable=Yes

Write-Host "Complete..."
