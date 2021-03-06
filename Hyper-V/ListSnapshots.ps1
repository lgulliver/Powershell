# Prompt for the Hyper-V Server to use
$HyperVServer = Read-Host "Specify the Hyper-V Server to use (enter '.' for the local computer)"
 
# Prompt for the virtual machine to use
$VMName = Read-Host "Specify the name of the virtual machine"
 
# Get the management service
$VMMS = gwmi -namespace root\virtualization Msvm_VirtualSystemManagementService -computername $HyperVServer
 
# Get the virtual machine object
$VM = gwmi MSVM_ComputerSystem -filter "ElementName='$VMName'" -namespace "root\virtualization" -computername $HyperVServer
 
# Get snapshot objects associated with the virtual machine
$Snapshots = gwmi -namespace root\virtualization -Query "Associators Of {$VM} Where AssocClass=Msvm_ElementSettingData ResultClass=Msvm_VirtualSystemSettingData" 

write-host
write-host $VMName "has the following snapshots:" 

# Display a formatted list of snapshots
$Snapshots | sort CreationTime | Format-Table -Property @{n='Snapshot Name';e={$_.ElementName}}
