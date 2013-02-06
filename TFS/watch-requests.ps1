param (
    [string]$baseServerUrl = "http://tkbgitvstfat01:8080",
    [int]$secondsBetweenUpdates = 10
)

function requests_raw
{
   param ([string]$baseServerUrl = $(throw 'baseServerUrl is required'))

   $wc = new-object System.Net.WebClient
   $wc.Credentials = [System.Net.CredentialCache]::DefaultCredentials
   $url = "$baseServerUrl/VersionControl/v1.0/administration.asmx/QueryServerRequests"
   $x = [xml]$wc.DownloadString($url)
   $wc.Dispose()
   $x.arrayofanytype.anytype
}

for (;;) { 
    clear
    requests_raw $baseServerUrl | sort -desc executiontime | ft -a user,webmethod,executiontime,serverprocessid
    sleep $secondsBetweenUpdates
}
