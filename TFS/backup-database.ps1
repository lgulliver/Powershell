# small rewrite to version done by Sung Kim
# http://monadblog.blogspot.com/2006/07/back-up-sql-server-database-with-sql.html

param (
    [string]$dbName = $(throw 'Specify Database name to backup'),
    [string[]]$deviceNames = $(throw 'Specify device name(s)'),
    [Microsoft.SqlServer.Management.Smo.Server]$server = '.',
    [Microsoft.SqlServer.Management.Smo.DeviceType]$deviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File,
    [switch]$overwrite,
    [switch]$differential
)

trap {
    write-error 'Failure during backup'
    break
}

[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')

$smoBackup = New-Object Microsoft.SqlServer.Management.Smo.Backup
$smoBackup.Database = $dbName
$smoBackup.Initialize = $overwrite
$smoBackup.Incremental = $differential

# Add backup devices to backup database
foreach ($deviceName in $deviceNames)
{
    $smoBackupItem = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem($deviceName, $deviceType)
    $smoBackup.Devices.Add($smoBackupItem)
}

if ($overwrite) {
    write-warning "Overwriting existing backup set"
}
$smoBackup.SqlBackup($server)
if ($differential) {
    write-host -NoNewLine -F Blue "Differential Backup: "
}

write-host -NoNewLine "$($dbName) has been backed up to "
write-host -ForegroundColor Cyan -NoNewLine "$($deviceNames)"
write-host " successfully"
