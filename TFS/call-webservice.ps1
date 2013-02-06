param (
    [string] $webServiceUrl = $(throw 'webServiceUrl is required'), 
    [string] $request = $(throw 'request is required'),
    [string] $soapaction = $null
)

$webClient = new-object 'system.net.webclient'
$webClient.UseDefaultCredentials = $true
$webClient.Headers['Content-Type'] = 'text/xml; charset=utf-8'
if ($soapaction)
{
    $webClient.Headers['SOAPAction'] = $soapaction
    write-debug "Setting SOAPAction header to $soapaction"
}

write-debug "Sending to $webServiceUrl request of $request"
$requestBytes = [text.encoding]::utf8.getbytes($request)
trap {
    write-error "Could not access $webServiceUrl"
    break
}
$respBytes = $webClient.UploadData($webServiceUrl, 'POST', $requestBytes)
write-debug "Got back $($respBytes.Count) bytes"

$webClient.Dispose()
$respString = [text.encoding]::utf8.getstring($respBytes)
write-debug "Got back response string of $($respString)"

$respString
