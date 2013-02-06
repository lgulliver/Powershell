$date = Get-Date -Format d.MMMM.yyyy 
$destination = "\\pathtodestination" 
$path = test-Path $destination 
$source = "\\pathtosource"

$smtp = "mail.server.com" 
$from = "donotreply@server.com" 
$to = "example@server.com" 
$body = "Log File of Copy Job is attached, backup happened at $date" 
$subject = "Backup on $date" 

if ($path -eq $true) { 
    write-Host "Directory exists" 
    

    copy-item -Path "$source\*" -Recurse -Destination $destination  -Force        
    


    $backup_log = Dir $destination | out-File "$destination\backup_log.txt"
    $attachment = "$destination\backup_log.txt" 

    send-MailMessage -SmtpServer $smtp -From $from -To $to -Subject $subject -Attachments $attachment -Body $body -BodyAsHtml 

               
    write-host "Backup Successful"
}