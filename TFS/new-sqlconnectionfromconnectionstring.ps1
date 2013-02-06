param(
   [string] $connectionString = $(throw 'connection string is required')
)

write-debug "Attempting to contact via connection string $connectionString"

# Load the System.Data assembly for access to SQL Server
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Data")

$serverConn = new-object 'system.data.sqlclient.SqlConnection' $connectionString
$serverConn.Open()
$serverConn
