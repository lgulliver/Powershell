# load a couple of assemblies we expect to need
[void][reflection.assembly]::loadwithpartialname('microsoft.teamfoundation.versioncontrol.client')
[void][reflection.assembly]::loadwithpartialname('system.windows.forms')

function check_assemblies_at_path([string] $registryPath) 
{
    if (!(test-path $registryPath))
    {
        write-debug "skipping registry path which does not exist: $registryPath"
        return
    }
    $policiesKey = get-item $registryPath

    $policyAssemblyNames = $policiesKey.GetValueNames()

    foreach ($policyAssemblyName in $policyAssemblyNames)
    {
        $policyAssemblyPath = $policiesKey.GetValue($policyAssemblyName)
        if ($policyAssemblyPath)
        {
            $pathBaseName = $policyAssemblyPath -replace '.*\\(.*).dll','$1'
            if ($pathBaseName -ne $policyAssemblyName) 
            {
                write-warning ('Registry value {0} should be changed to match assembly base name {1}' -f $policyAssemblyName, $pathBaseName)
            }
            if (!(test-path $policyAssemblyPath))
            {
                write-warning "File location specified for $policyAssemblyName is missing: $policyAssemblyPath"
                continue
            }
            $policyAsm = [reflection.assembly]::LoadFrom($policyAssemblyPath)
        }
        else
        {
            $policyAsm = [reflection.assembly]::Load($policyAssemblyName)
        }
        $policyTypes = @($policyAsm.gettypes() | 
            ?{ [microsoft.teamfoundation.versioncontrol.client.ipolicydefinition].isassignablefrom($_) -and
               [microsoft.teamfoundation.versioncontrol.client.ipolicyevaluation].isassignablefrom($_) })

        write-debug ('Found {0} policy type(s) in assembly {1}: {2}' -f $policyTypes.Length, $policyAssemblyName, $policyTypes)
        foreach ($policyType in $policyTypes)
        {
            write-debug "Examining $policyType"
            if ([attribute]::getcustomattribute($policyType, [SerializableAttribute]) -eq $null)
            {
                write-warning "Policy type $policyType fails the check for [Serializable]"
            }
            if (!$policyType.IsClass)
            {
                write-warning "Policy type $policyType fails the check for being a class"
            }
            if ($policyType.IsAbstract)
            {
                write-warning "Policy type $policyType fails the check for not being abstract"
            }
            if (!$policyType.IsPublic)
            {
                write-warning "Policy type $policyType fails the check for being public"
            }
            if ($policyType.GetConstructor(@()) -eq $null)
            {
                write-warning "Policy type $policyType fails the check for having a zero-arg constructor"
            }
        }
    }    
}

check_assemblies_at_path('HKLM:\SOFTWARE\Microsoft\VisualStudio\8.0\TeamFoundation\SourceControl\Checkin Policies')
check_assemblies_at_path('HKCU:\SOFTWARE\Microsoft\VisualStudio\8.0\TeamFoundation\SourceControl\Checkin Policies')
