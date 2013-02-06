param(
   [string] $serverName = '.',
   [string] $additionalWhereClause = '1=1',
   [string] $databaseName = 'TfsActivityLogging',
   [int] $maxRowsPerCheck = 10,
   [int] $secondsBetweenChecks = 10
)

begin
{
    # Load the System.Data assembly for access to SQL Server
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Data")
    # generate a connection string
    $builder = new-object 'system.data.sqlclient.SqlConnectionStringBuilder'
    $builder['Server'] = $serverName;
    $builder['Integrated Security'] = $true;
    $builder['Initial Catalog'] = $databaseName;
    # Establish the connection to the server
    $serverConn = new-object 'system.data.sqlclient.SqlConnection' $builder.ConnectionString
    $serverConn.Open()
    # Formulate the query we'll run
    $query = "
        select top $maxRowsPerCheck * from tbl_command
        where commandid > @commandid
        and $additionalWhereClause
        order by commandid desc
    "
    # Create the SqlCommand
    $sqlCommand = new-object 'system.data.sqlclient.SqlCommand' $query, $serverConn
    [void]$sqlCommand.Parameters.Add('@commandid', [system.data.sqldbtype]::int)
    # var for tracking where we are in the table so far
    $lastCommandId = 0;

    function fetchLatestRows {
        $sqlCommand.Parameters['@commandid'].Value = $lastCommandId
        $rdr = $sqlCommand.ExecuteReader()
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
    while ($true)
    {
        # wrap the call with @() (explicit array reference) to force an array even if it's only 1 row
        $results = @(fetchLatestRows $lastCommandId)
        if ($results -ne $null)
        {
            # save off the highest command id so we know where we're at in the table
            $lastCommandId=$results[0].CommandId;
            # reverse the results so they display chronologically
            [array]::reverse($results)
            # include -auto so we get the best fit for content
            $results | select StartTime,ExecutionTime,Command,Application,IdentityName,IPAddress | ft -auto
        }
        else
        {
            write-host "...[No activity]..."
        }
        start-sleep $secondsBetweenChecks;
    }
}
