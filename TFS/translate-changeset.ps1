param (
    [int] $changeset = $(throw 'changeset is required'),
    [string] $system = $(if ($changeset -lt 2000000) { 'TFS' } else { 'Source' })
)

$updateSdReporting = connect-webservice 'http://vmbgitvstfutl01/updatesdreporting/updatesdreporting.asmx?WSDL'
$updateSdReporting.GetMirroredChangesetID($changeset, $system)
