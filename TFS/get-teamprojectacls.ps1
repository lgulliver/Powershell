param (
    [string] $server = $(throw 'must specify a server'),
    [string[]] $teamProjectNames
)

$tfs = get-tfs $server
$teamProjects = $tfs.css.ListProjects()

# if they specified a particular set of team project names, just use those
if ($teamProjectNames)
{
    $teamProjects = $teamProjects | ?{ $teamProjectNames -contains $_.Name }
}

foreach ($teamProject in $teamProjects)
{
    write-host "ACL's for team project $($teamProject.Name)"

    $acls = $tfs.auth.ReadAccessControlList('$PROJECT:' + $teamProject.Uri)
    foreach ($acl in $acls)
    {
        $readableName = convertto-readableDisplayName $tfs $acl.Sid
        $allowDenyString = "foo";
        if ($_.Deny) { $allowDenyString="DENY" } else { $allowDenyString="ALLOW" }
        write-host "`t$($acl.ActionId)`t$allowDenyString`t$readableName"
    }
}
