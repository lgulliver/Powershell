param (
    [int[]] $featureIds = $(throw 'featureIds must be specified'),
    [switch] $update
)

$tfs = get-tfs http://tkbgitvstfat01:8080

$taskQuery = @'
    select [Microsoft.VSTS.Scheduling.RemainingWork],[Microsoft.VSTS.Scheduling.CompletedWork]
    from workitems
    where [Microsoft.VSTS.Dogfood.FeatureID]="{0}"
    and [system.reason] != "Obsolete"
    and [system.workitemtype] = "task"
'@

foreach ($featureId in $featureIds)
{
    write-host
    write-host "*** Processing feature $featureId"

    trap { "Cannot find feature id $featureId"; break; } $feature = $tfs.wit.GetWorkItem($featureId)
    $currentRemainingWork = $feature['Microsoft.VSTS.Scheduling.RemainingWork']
    $currentCompletedWork = $feature['Microsoft.VSTS.Scheduling.CompletedWork']
    write-host "Current value for feature remaining work: $currentRemainingWork"
    write-host "Current value for feature completed work: $currentCompletedWork"

    $tasks = @($tfs.wit.Query($taskQuery -f $featureId))

    $remainingWorkTotal = $(
            $tasks | %{ $_['Microsoft.VSTS.Scheduling.RemainingWork'] } | measure-object -sum
        ).sum

    $completedWorkTotal = $(
            $tasks | %{ $_['Microsoft.VSTS.Scheduling.CompletedWork'] } | measure-object -sum
        ).sum

    write-host "Calculated remaining work: $remainingWorkTotal"
    write-host "Calculated completed work: $completedWorkTotal"

    if ($currentRemainingWork -ne $remainingWorkTotal -or
        $currentCompletedWork -ne $completedWorkTotal)
    {
        if ($update)
        {
            write-host "Updating feature $featureId values"
            $feature['Microsoft.VSTS.Scheduling.RemainingWork'] = $remainingWorkTotal
            $feature['Microsoft.VSTS.Scheduling.CompletedWork'] = $completedWorkTotal
            $feature.Save()
            write-host "feature $featureId values updated successfully"
        }
        else
        {
            write-host "Values for feature $featureId are wrong, but -update switch was not specified"
        }
    }
    else
    {
        write-host "Feature $featureId values were already up to date"
    }
}
