function forest() {
    param(
        [string]$domain,
        [string]$password,
        [string]$dc1
    )
    
    $secpw = ConvertTo-SecureString $password -AsPlainText -Force
    Write-Host 'Installing into forest...'
    Import-Module ADDSDeployment
    $credentials = New-Object System.Management.Automation.PSCredential("VANLIEFFERINGE\Administrator",$secpw)
    Install-ADDSDomainController -DomainName $domain -ReplicationSourceDC "$dc1.$domain" -credential $credentials -InstallDns -createDNSDelegation:$false -NoRebootOnCompletion -SafeModeAdministratorPassword $secpw -Force
}
