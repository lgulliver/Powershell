# Load the VMM CmdLets
Add-PSSnapIn Microsoft.SystemCenter.VirtualMachineManager

function ProcessWMIJob 
{  
    param 
    (  
        [System.Management.ManagementBaseObject]$Result 
    )  

    if ($Result.ReturnValue -eq 4096) 
    {  
        $Job = [WMI]$Result.Job 

        while ($Job.JobState -eq 4) 
        {  
            Write-Progress $Job.Caption "% Complete" -PercentComplete $Job.PercentComplete 
            Start-Sleep -seconds 1 
            $Job.PSBase.Get() 
        }  
        if ($Job.JobState -ne 7) 
        {  
            Write-Error $Job.ErrorDescription 
            Throw $Job.ErrorDescription 
        }  
        Write-Progress $Job.Caption "Completed" -Completed $TRUE 
    }  
    elseif ($Result.ReturnValue -ne 0) 
    {  
        Write-Error "Hyper-V WMI Job Failed!" 
        Throw $Result.ReturnValue 
    }  
} 


$VMManagementService = Get-WmiObject -Namespace root\virtualization -Class Msvm_VirtualSystemManagementService 
$SourceVm = Get-WmiObject -Namespace root\virtualization -Query "Select * From Msvm_ComputerSystem Where ElementName='VM1'" 

$result = $VMManagementService.CreateVirtualSystemSnapshot($SourceVm) 
ProcessWMIJob($result)