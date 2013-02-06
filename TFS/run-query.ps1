param(
   $sqlConn = $(throw 'server name or sql connection is required'),
   [string] $query = $(throw 'query is required'),
   [string] $database = 'master'
)

# if it is not already a sqlconnection (for instance, it's a string)
# then make a sql connection from it
if ($sqlConn -isnot [system.data.sqlclient.SqlConnection])
{
    $sqlConn = new-sqlconnection $sqlConn $database
}

$sqlCommand = new-object 'system.data.sqlclient.SqlCommand' $query, $sqlConn
$rdr = $sqlCommand.ExecuteReader()

while($rdr.Read())
{
    if ($rdr.FieldCount -eq 1)
    {
        # single value, just return it
        $rdr.GetValue(0)
    }
    else
    {
        # multiple columns, create a custom result object
        $row = new-object psobject
        $row.psobject.typenames[0] = "SqlResultObject"
        for($c = 0; $c -lt $rdr.FieldCount; $c++) 
        {
            $row | add-member noteproperty $rdr.GetName($c) $rdr.GetValue($c) 
        }
        $row
    }
}
$rdr.dispose();
$sqlCommand.dispose();
$sqlConn.dispose();
