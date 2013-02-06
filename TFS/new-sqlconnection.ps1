param(
   [string] $serverName = $(throw 'serverName is required'),
   [string] $database = 'master'
)

$connectionString = "Server=$serverName;Database=$database;Integrated Security=SSPI"

new-sqlconnectionfromconnectionstring $connectionString
