param ([string] $url)

    $webClient = new-object 'system.net.webclient'
    $webClient.UseDefaultCredentials = $true
    $resp = $webClient.DownloadString($url)
    $webClient.Dispose()
    $resp