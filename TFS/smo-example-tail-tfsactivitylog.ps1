param(
   [string] $serverName = $(throw 'serverName is required'),
   [string] $additionalWhereClause = '1=1',
   [string] $databaseName = 'TfsActivityLogging',
   [int] $maxRowsPerCheck = 50,
   [int] $secondsBetweenChecks = 10
)

begin
{
    # Load the SMO assembly
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    # Establish the connection to the server
    $serverConn = (new-object ('microsoft.sqlserver.management.smo.server') $serverName).ConnectionContext;

    function executesql(
       [string] $query = $(throw 'query is required')
    ) {
        #write-host ('Executing {0} on {1}' -f $query, $serverName)
        $rdr = $serverConn.executeReader($query)
        while($rdr.Read())
        {
            $row = new-object psobject
            $row.psobject.typenames[0] = "TfsActivityLoggingObject"
            for($c = 0; $c -lt $rdr.FieldCount; $c++) 
            { 
                $row | add-member noteproperty $rdr.GetName($c) $rdr.GetValue($c) 
            }
            $row
        }
        $rdr.close();
    }
}

process
{
    $lastCommandId = 0;
    while ($true)
    {
        $query = "
            select top $maxRowsPerCheck * from $databaseName..tbl_command
            where commandid > $lastCommandId
            and $additionalWhereClause
            order by commandid desc
        "

        # wrap the call with @() (explicit array reference) to force an array even if it's only 1 row
        $results = @(executesql $query)
        if ($results -ne $null)
        {
            write-host "Got $($results.count) activity log row(s)"
            $lastCommandId=$results[0].CommandId;
            $results | select StartTime,ExecutionTime,Command,Application,IdentityName,IPAddress | ft
        }
        else
        {
            write-host "...[No activity]..."
        }
        start-sleep $secondsBetweenChecks;
   }
}
