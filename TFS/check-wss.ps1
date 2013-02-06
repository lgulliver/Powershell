param ([string] $serverUrl = $(throw 'serverUrl parameter is required'))

$tfs = get-tfs $serverUrl
$wssInterfaces = $tfs.reg.GetRegistrationEntries('wss')[0]

$urlsToCheck = 'BaseServerUrl','WssAdminService'

$wssInterfaces | ?{ $urlsToCheck -contains $_.Name } | %{
    $result = ping-url $_.Url
    $color = 'green'
    if ($result -match 'Failed') { $color = 'red' }
    write-host -foreground $color ('Result of pinging {0}: {1}' -f $_, $result)
}
