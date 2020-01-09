# Script 3 for WIN-DC2

$dns1 = '192.168.100.10'
$dns2 = '192.168.100.20'

Write-Host "Fixing DNS settings after reboot..."

Set-DnsClientServerAddress -InterfaceAlias "LAN" -ServerAddresses($dns1,$dns2)
Set-DnsClientServerAddress -InterfaceAlias "WAN" -ResetServerAddresses

Write-Host "Complete..."
