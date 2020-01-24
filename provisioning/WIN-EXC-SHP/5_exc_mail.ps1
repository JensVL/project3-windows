# Script 5 for WIN-EXC-SHP

# set up mail service
Write-Host "Installing Exchange server mail..."

$iso = "c:\scripts\WIN-EXC-SHP\ExchangeServer2016-x64-cu14.iso"

#check for iso, if doesnt exist, download
Write-Host "checking or downloading iso..."
if (!(Test-Path("$iso"))) {
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/f/4/e/f4e4b3a0-925b-4eff-8cc7-8b5932d75b49/ExchangeServer2016-x64-cu14.iso","$iso")
}
# mount exchange iso
$isodrive = (Get-DiskImage -ImagePath $iso | Get-Volume)
if (!($isodrive)) {
    Write-Host 'Mounting iso...'
    Mount-DiskImage -ImagePath $iso
} else {
    Write-Host 'Already mounted...'
}

$isodrive = (Get-DiskImage -ImagePath $iso | Get-Volume).DriveLetter
Set-Location "${isodrive}:"

Invoke-Expression "& .\Setup.exe /mode:Install /role:Mailbox /OrganizationName:'JVL' /IAcceptExchangeServerLicenseTerms"

Write-Host "Setting up mail..."
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$users = Get-ADUser -filter {userAccountControl -eq 512} -properties *
$users | ForEach-Object (enable-mailbox -Identity $_.Name -Database (get-mailboxdatabase).name)

New-SendConnector -Name 'E-mail SMTP' -AddressSpaces * -Internet -SourceTransportServer "WIN-EXC-SHP.vanliefferinge.periode1"
Install-WindowsFeature ADLDS

Write-Host "Mail setup complete..."

# load next script
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name ResumeScript -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe -executionpolicy bypass -file c:\scripts\WIN-EXC-SHP\6_shp_prereq.ps1"

Restart-Computer
