Function ConvertTo-UnixTimeNanosecond {
    <#
        .SYNOPSIS
            Converts a datetime object to a Unix time code in nanoseconds.

        .DESCRIPTION
            This is the datetime format Influx expects for writing the (optional) timestamp field.

        .PARAMETER Date
            The date/time to be converted.

        .EXAMPLE
            '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeNanosecond
            
            Result
            -------------------
            1483274062120000000
    #>      
    [cmdletbinding()]
    [OutputType([long])]
    Param(
        [parameter(ValueFromPipeline)]
        [datetime]
        $Date
    )
    Process {
        [long]((New-TimeSpan -Start (Get-Date -Date '1970-01-01') -End (($Date).ToUniversalTime())).TotalSeconds * 1E9)
    }
}