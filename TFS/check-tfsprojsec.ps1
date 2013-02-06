param ($serverName = $(throw 'please specify a TFS server name'))

$tfs = get-tfs $serverName

foreach ($project in $tfs.css.ListProjects())
{
    $objectId = [Microsoft.TeamFoundation.PermissionNamespaces]::Project + $project.Uri
    foreach ($ace in $tfs.auth.ReadAccessControlList($objectId))
    {
        $aceIdentity = $tfs.gss.ReadIdentity('Sid', $ace.Sid, 'None')
        $isGroup = $aceIdentity.SecurityGroup -or
                   $aceIdentity.Type -eq 'WindowsGroup' -or
                   $aceIdentity.Type -eq 'ApplicationGroup'
        if (-not $isGroup)
        {
            write-warning ('ACE identity {0} of team project {1} is not a group' -f
                           $aceIdentity.DisplayName, $project.Name)
        }
    }
}
