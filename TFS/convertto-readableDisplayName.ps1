param(
    $tfs,
    [string] $displayName = $(throw 'must specify a display name'),
    [string] $domainName
)

# due to bug in PS1, can't specify this in the param listing
if ($tfs -isnot [microsoft.teamfoundation.client.teamfoundationserver])
{
    throw 'must specify a TeamFoundationServer instance'
}

# if the display name looks like a SID, convert it to domain/display
if ($displayName -match '^S-1-')
{
    $identity = $tfs.gss.ReadIdentityFromSource('sid', $displayName)
    $domainName = $identity.Domain
    $displayName = $identity.DisplayName
}

# if it's empty, leave it alone (global identities)
if (!$domainName) { return $displayName }

# if it's a vstfs uri, use CSS to translate it to a team project prefix
if ($domainName -match '^vstfs://')
{
    $projectName = $tfs.css.GetProject($domainName).Name
    return "[$projectName]\$displayName"
}

# all others, just prefix it
return "$domainName\$displayName"
