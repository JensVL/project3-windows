# useful functions 

# set database perms for a user - add to role
function set_sql_perm() {
    param(
        [Microsoft.SQLServer.Management.Smo.Server]$server,
        [string]$sqlusernameFc,
        [string]$role
    )
    $login = New-Object Microsoft.SqlServer.Management.Smo.Login $server, "$sqlusernameFc"
    $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::WindowsUser
    $login.AddToRole($role)
}

# set as much memory as possible to allow sccm to install faster

# helper function to set_sql_mem
function get_sql_max_mem() { 
    $memtotal = 8192
    $min_os_mem = 2048
    if ($memtotal -le $min_os_mem) {
        Return $null
    }
    if ($memtotal -ge 8192) {
        $sql_mem = $memtotal - 2048
    } else {
        $sql_mem = $memtotal * 0.8
    }
    return [int]$sql_mem
}

# actual set function
function set_sql_mem() {
    param(
        [Microsoft.SQLServer.Management.Smo.Server]$serverFc,
        [int]$maxmem = $null, 
        [int]$minmem = 0
    )
    if ($minmem -eq 0) {
        $minmem = $maxmem
    }
    if ($serverFc.status) {
        $serverFc.Configuration.MaxServerMemory.ConfigValue = $maxmem
        $serverFc.Configuration.MinServerMemory.ConfigValue = $minmem   
        $serverFc.Configuration.Alter()
    }
}
