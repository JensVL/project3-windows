# Script 7 for WIN-EXC-SHP

Write-Host "Installing Sharepoint..."

#set location on iso
$iso = "c:\scripts\officeserver.img"
$isodrive = (Get-DiskImage -ImagePath $iso | Get-Volume).DriveLetter
Set-Location "${isodrive}:"

#run install
Start-Process ".\setup.exe" -ArgumentList "/config `"c:\scripts\WIN-EXC-SHP\shp-install-config.xml`"" -WindowStyle Minimized -wait | Out-Null
Start-Process ".\setup.exe" -ArgumentList "/config `"c:\scripts\WIN-EXC-SHP\shp-install-config.xml`"" -WindowStyle Minimized -wait | Out-Null

Add-PSSnapIn Microsoft.SharePoint.PowerShell

Write-Host "install complete..."

# load next script
& "c:\scripts\WIN-EXC-SHP\8_shp_farm.ps1"
