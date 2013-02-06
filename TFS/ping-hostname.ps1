param ([string] $hostname)

    trap { 
#        'Failed to ping {0}: [{1}] {2}' -f 
#            $url, $_.exception.getbaseexception().gettype().name, $_.exception.getbaseexception().message
        'Failed [{0}] {1}' -f 
            $_.exception.getbaseexception().gettype().name, $_.exception.getbaseexception().message
        continue 
    }
    & {
        [void](new-object 'system.net.networkinformation.ping').Send($hostname)
        # "Successfully pinged $hostname"
	'Successful'
    }
