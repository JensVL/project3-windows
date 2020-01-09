# Script 5 for WIN-DC1

$zone_exists=(Get-DnsServerZone -Name "vanliefferinge.periode1")
if (!$zone_exists) {
    Write-Host 'Adding primary DNS zone and enabling replication...'
    Add-DnsServerPrimaryZone -Name "vanliefferinge.periode1" -ReplicationScope "Domain" -DynamicUpdate "Secure"
    Set-DnsServerPrimaryZone -Name "vanliefferinge.periode1" -SecureSecondaries "TransferToZoneNameServer"
}

Write-Host 'Adding A records...'
Add-DnsServerResourceRecordA -Name "WINSQLSCCM" -ZoneName "vanliefferinge.periode1" -IPv4Address "192.168.100.30"
Add-DnsServerResourceRecordA -Name "WINEXCSHP" -ZoneName "vanliefferinge.periode1" -IPv4Address "192.168.100.40"

Write-Host 'Adding MX and CNAME records..'
Add-DnsServerResourceRecordMX -Name "WINEXCSHP" -ZoneName "vanliefferinge.periode1" -MailExchange "mail.vanliefferinge.periode1" -Preference 100
Add-DnsServerResourceRecordCName -Name "owa" -ZoneName "vanliefferinge.periode1" -HostNameAlias "mail.vanliefferinge.periode1"

Write-Host "Complete..."
