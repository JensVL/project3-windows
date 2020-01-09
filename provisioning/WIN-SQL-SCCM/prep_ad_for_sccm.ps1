# Extra script for WIN-SQL-SCCM

Write-Host "Preparing AD Schema..."

# Add server to AD
Write-Host "Adding WIN-SQL-SCCM to AD..."
New-ADComputer -Name "WIN-SQL-SCCM"

Write-Host 'Connecting to ADSIedit...'
$ADSIconnection = [ADSI]"LDAP://localhost:389/cn=System,dc=vanliefferinge,dc=periode1"

Write-Host 'Creating container...'
$SysManContainer = $ADSIconnection.Create("container", "cn=System Management")
$SysManContainer.SetInfo()

# Set perms
Write-Host 'Setting permissions for container...'
$SystemManagementCN = [ADSI]("LDAP://localhost:389/cn=System Management,cn=System,dc=vanliefferinge,dc=periode1")
$SCCMserver = get-adcomputer "WIN-SQL-SCCM"
$SID = [System.Security.Principal.SecurityIdentifier] $SCCMserver.SID
$ServerIdentity = [System.Security.Principal.IdentityReference] $SID

$perms = [System.DirectoryServices.ActiveDirectoryRights] "GenericAll"
$allow = [System.Security.AccessControl.AccessControlType] "Allow"
$inheritall = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"

# Apply perms
$permrule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
$ServerIdentity,$perms,$allow,$inheritall

$SystemManagementCN.psbase.ObjectSecurity.AddAccessRule($permrule)
$SystemManagementCN.psbase.commitchanges()

Write-Host "AD prep complete..."
