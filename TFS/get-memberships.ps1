param (
    [string] $accountName = $(throw 'accountName is needed'),
    [string] $server = '.', # defaults to finding tfs by current dir
    [string] $membershipType = 'direct' # defaults to just direct memberships
)

$tfs = get-tfs $server

$memberOfSids = $tfs.gss.ReadIdentity('accountName', $accountName, $membershipType).memberof

$memberOfIdentities = $memberOfSids | %{
    add-member -in $_ noteproperty FullDisplayName (
        convertto-readableDisplayName $tfs $_
    ) -passthru
}

$memberOfIdentities
