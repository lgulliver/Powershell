param(
    [string] $iisPath = 'W3SVC/1/root',
    [string] $computer = '.'
)

$MS = new-object management.ManagementScope 
$ms.Options.Authentication = 'PacketIntegrity'

$mp = new-object Management.ManagementPath
$mp.path = '\\server\root\MicrosoftIISv2:IIsIPSecuritySetting'

New-Object Management.managementclass($ms,$mp,$null)


trap
{
    write-error "Failed to read from WMI for IIS path $iisPath: $_"
    break
}
$ipSecurity = gwmi -query "select * from IIsIPSecuritySetting where name='$iisPath'" `
                   -namespace root/MicrosoftIISv2 `
                   -computer $computer

$resultObject = new-object psobject


if ($ipSecurity.GrantByDefault)
{
    add-member -in $resultObject NoteProperty GrantByDefault $true
    add-member -in $resultObject NoteProperty DeniedIPAddresses $ipSecurity.IPDeny
    add-member -in $resultObject NoteProperty DeniedDomains $ipSecurity.DomainDeny
}
else
{
    add-member -in $resultObject NoteProperty GrantByDefault $false
    add-member -in $resultObject NoteProperty GrantedIPAddresses $ipSecurity.IPGrant
    add-member -in $resultObject NoteProperty GrantedDomains $ipSecurity.DomainGrant
}
$resultObject
