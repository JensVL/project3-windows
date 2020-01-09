# Script 4 for WIN-SQL-SCCM

. "c:\vagrant\provisioning\sql.ps1"

Write-Host "Setting up admin permissions..."

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlEnum") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
 
$connection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
$server = New-Object Microsoft.SqlServer.Management.Smo.Server $connection
 
# Allow domain admin to create db

$sqlusername = 'VANLIEFFERINGE\Administrator'

set_sql_perm $server $sqlusername "securityadmin"
set_sql_perm $server $sqlusername "sysadmin"
set_sql_perm $server $sqlusername "dbcreator"

# Set min and max server memory
set_sql_mem $server (get_sql_max_mem)

# load in next script
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name ResumeScript -Value "C:\Windows\system32\WindowsPowerShell\v1.0\Powershell.exe -executionpolicy bypass -file C:\scripts\WIN-SQL-SCCM\5_sccm_install.ps1"
 
Restart-Computer
