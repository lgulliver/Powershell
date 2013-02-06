param ( 
    [string] $content = $(throw 'content is required'),
    [string] $regex = $(throw 'regex is required')
) 

$returnMatches = @()

write-debug "Running regex $($regex) against content of $($content)"
$resultingMatches = [regex]::Matches($content, $regex, 'IgnoreCase') 
foreach ($match in $resultingMatches)
{  
    write-debug "Found match $($match)"
    $returnMatches += $match.Groups[1].Value.Trim()
} 

$returnMatches    
