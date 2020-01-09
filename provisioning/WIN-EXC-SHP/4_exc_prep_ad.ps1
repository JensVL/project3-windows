# Script 4 for WIN-EXC-SHP

Write-Host "Preparing AD and schema..."

$iso = "c:\scripts\ExchangeServer2016-x64-cu14.iso"

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

# set location on iso
$isodrive = (Get-DiskImage -ImagePath $iso | Get-Volume).DriveLetter
Set-Location "${isodrive}:"

# run preparation
Write-Host 'Preparing Schema...'
Invoke-Expression "& .\setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms"

Write-Host 'Preparing AD...'
Invoke-Expression "& .\Setup.exe /PrepareAD /OrganizationName:'JVL' /IAcceptExchangeServerLicenseTerms"

Write-Host 'Preparing domains...'
Invoke-Expression "& .\Setup.exe /IAcceptExchangeServerLicenseTerms /PrepareAllDomains"

# load next script
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name ResumeScript -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe -executionpolicy bypass -file c:\scripts\WIN-EXC-SHP\5_exc_mail.ps1"

Restart-Computer