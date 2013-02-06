[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") 

function ObjectViewer { 
$form = new-object "System.Windows.Forms.Form" 
$form.Size = new-object System.Drawing.Size @(600,600) 
$PG = new-object "System.Windows.Forms.PropertyGrid" 
$PG.Dock = [System.Windows.Forms.DockStyle]::Fill 
$form.text = "$args" 
$PG.selectedobject = $args[0].mshObject.baseobject 
$form.Controls.Add($PG) 
$form.topmost = $true 
$form.showdialog() 
} 
set-Alias OV ObjectViewer 