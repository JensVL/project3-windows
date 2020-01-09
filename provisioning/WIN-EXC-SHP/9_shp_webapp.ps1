# Script 9 for WIN-EXC-SHP

Write-Host "Configuring webapp..."

Add-PsSnapin "Microsoft.SharePoint.PowerShell" -EA 0
 
#vars
$AppPoolAccount = "VANLIEFFERINGE\Administrator"
$ApplicationPoolName ="SharePoint - 8081"
$ContentDatabase = "SharePoint_ContentDB"
$DatabaseServer = "WIN-SQL-SCCM"
$Url = "http://WIN-EXC-SHP:8081/"
$Name = "WIN-EXC-SHP - Documents"
$Description = "SharePoint Site"
$SiteCollectionTemplate = 'STS#0'

# set up webapp
Write-Host 'Creating New-SPWebApplication...'
New-SPWebApplication -ApplicationPool $ApplicationPoolName -ApplicationPoolAccount (Get-SPManagedAccount $AppPoolAccount) -Name $Description -AuthenticationProvider (New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication) -DatabaseName $ContentDatabase -DatabaseServer $DatabaseServer -URL $Url

Write-Host 'Creating New-SPSite...'
New-SPSite -Url $Url -Name $Name -Description $Description -OwnerAlias $AppPoolAccount -Template $SiteCollectionTemplate

           
$w = Get-SPWebApplication $Url
$w.Properties["portalsuperuseraccount"] = $AppPoolAccount
$w.Properties["portalsuperreaderaccount"] = $AppPoolAccount
$w.Update()

Write-Host "install complete..."

iisreset /restart
