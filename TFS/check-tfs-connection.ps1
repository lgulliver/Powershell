param ([string] $server = $(throw 'TFS server name or uri is required'))

# first normalize this to a url in case the user specifies a friendly name
$server = normalize-tfserverurl $server

# can we get the registered tools from this server?
trap {
   write-error "Failed to access registration data from $server"
   break
} $toolsResponse = get-tfs-registrationdata $server
write-host "Successfully looked up registration data from TFS server $server"

$toolsResponse
