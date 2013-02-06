param ([string] $serverUrl = $(throw 'serverUrl parameter is required'))

# try to get the registration entries xml
trap { 
    "Could not fetch registration data from $serverUrl"
    break
} $registrationEntries = (get-tfs-registrationdata $serverUrl)

# we have the xml, parse out the URL's
$registrationUrls = $registrationEntries.GetElementsByTagName('Url') | 
                    # only interested in the url string itself
                    %{ $_.'#text' } |
                    # filter to only full or partial URL's (no hostname/UNC)
                    ?{ $_ -match '^http' -or $_ -match '^/' } |
                    # filter out the ones we know will fail if called directly (base sharepoint, 2 TFVC ones)
                    ?{ $_ -notmatch '/sites$' -and $_ -notmatch '/item.asmx$' -and $_ -notmatch '/upload.asmx$' }

write-host ('Found {0} registered urls to check at server {1}' -f $registrationUrls.Count, $serverUrl)
write-host ''

$registrationUrls | %{
    #write-host "testing $_"
    $fullUrl = $_
    if ($fullUrl -notmatch '^http') { $fullUrl = $serverUrl + $fullUrl }
    $result = ping-url $fullUrl
    $color = 'green'
    if ($result -match 'Failed') { $color = 'red' }
    write-host -foreground $color ('Result of pinging {0}: {1}' -f $_, $result)
}
