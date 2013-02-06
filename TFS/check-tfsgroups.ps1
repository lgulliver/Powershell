param ($serverName = $(throw 'please specify a TFS server name'))

$tfs = get-tfs $serverName

foreach ($project in $tfs.css.ListProjects())
{
    foreach ($projectGroup in $tfs.gss.ListApplicationGroups($project.Uri))
    {
        $directMembers = $tfs.gss.ReadIdentity('Sid', $projectGroup.Sid, 'Direct')
        foreach ($memberSid in $directMembers.Members)
        {
            $member = $tfs.gss.ReadIdentity('Sid', $memberSid, 'None')
            $isGroup = $member.SecurityGroup -or
                       $member.Type -eq 'WindowsGroup' -or
                       $member.Type -eq 'ApplicationGroup'
            if (-not $isGroup)
            {
                write-warning ('Member {0} of group {1} in project {2} is not a group' -f
                               $member.DisplayName, $projectGroup.DisplayName, $project.Name)
            }
        }
    }
}
