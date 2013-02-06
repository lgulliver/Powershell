param (
    [int] $currentWebSiteId = $(throw 'please provide the current web site id'),
    [int] $newWebSiteId = $(throw 'please provide the desired web site id')
)

# from http://w3-4u.blogspot.com/2006/11/howto-change-id-of-iis-website.html
$adsutil = $env:systemdrive/inetpub/AdminScripts/adsutil.vbs

cscript $adsutil STOP_SERVER W3SVC/$currentWebSiteId
cscript $adsutil MOVE W3SVC/$currentWebSiteId W3SVC/$newWebSiteId
cscript $adsutil START_SERVER W3SVC/$newWebSiteId
