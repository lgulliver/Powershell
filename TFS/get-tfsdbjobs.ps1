param (
    [string] $serverName = $(throw 'serverName param is a required parameter'),
    [string] $matchString = 'TFS'
)

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

$server = new-object "Microsoft.SqlServer.Management.Smo.Server" $serverName

$server.JobServer.Jobs | ?{ $_.Name -match $matchString } | select Name,CurrentRunStatus,LastRunDate
