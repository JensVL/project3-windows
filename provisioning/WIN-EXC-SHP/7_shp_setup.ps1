# Script 7 for WIN-EXC-SHP

Write-Host "Installing Sharepoint..."

#set location on iso


$iso = "c:\scripts\WIN-EXC-SHP\officeserver.img"

Write-Host "Installing Sharepoint prereqs..."

Write-Host "checking or downloading iso..."
if (!(Test-Path("$iso"))) {
    (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/0/0/4/004EE264-7043-45BF-99E3-3F74ECAE13E5/officeserver.img","$iso")
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

#run install
Start-Process ".\setup.exe" -ArgumentList "/config `"c:\scripts\WIN-EXC-SHP\shp-install-config.xml`"" -WindowStyle Minimized -wait | Out-Null
Start-Process ".\setup.exe" -ArgumentList "/config `"c:\scripts\WIN-EXC-SHP\shp-install-config.xml`"" -WindowStyle Minimized -wait | Out-Null

Add-PSSnapIn Microsoft.SharePoint.PowerShell

Write-Host "install complete..."

# load next script
& "c:\scripts\WIN-EXC-SHP\8_shp_farm.ps1"
