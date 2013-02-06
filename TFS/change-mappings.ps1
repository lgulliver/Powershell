param(
  $workspace = $(throw 'must specify a workspace'),
  [string] $search = $(throw 'need a search string'),
  [string] $replace = $(throw 'need a replace string')
)

[void] [reflection.assembly]::loadwithpartialname("Microsoft.TeamFoundation.VersionControl.Client")

if ($workspace -is [string])
{
    $workspace = get-workspace $workspace
}

if ($workspace -isnot [microsoft.teamfoundation.versioncontrol.client.workspace])
{
    throw 'Must specify workspace as an instance of Workspace or a string that works with get-workspace'
}

[microsoft.teamfoundation.versioncontrol.client.workingfolder[]] $newMappings = @()
foreach ($existingMapping in $workspace.Folders)
{
    trap { 'Failure during creation of new mapping - check your search and replace strings'; break; }
    $newMapping = new-object 'microsoft.teamfoundation.versioncontrol.client.workingfolder' `
        ($existingMapping.ServerItem -replace $search,$replace), `
        ($existingMapping.LocalItem -replace $search,$replace), `
        $existingMapping.Type
    if ($existingMapping -ne $newMapping)
    {
        write-host ('Changing {0}={1} to {2}={3} [{4}]' -f
            $existingMapping.ServerItem, $existingMapping.LocalItem,
            $newMapping.ServerItem, $newMapping.LocalItem, $newMapping.Type)
        $needToUpdate=$true
    }
    else
    {
        write-host ('Keeping {0}={1} [{2}]' -f
            $existingMapping.ServerItem, $existingMapping.LocalItem, $existingMapping.Type)
    }
    $newMappings += $newMapping
}

if ($needToUpdate)
{
    $workspace.Update($workspace.Name, $workspace.Comment, $newMappings)
    write-host "Successfully updated mappings for workspace $($workspace.DisplayName)"
}
else
{
    write-host 'No mappings changed'
}
