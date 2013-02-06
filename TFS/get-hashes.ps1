param(
    [string] $file = $(throw 'a filename is required'),
    [string[]] $algorithms = ('mactripledes','md5','ripemd160','sha1','sha256','sha384','sha512')
)

foreach ($algorithm in $algorithms)
{
    "$algorithm hash for $file = $(hash $file $algorithm)"
}
