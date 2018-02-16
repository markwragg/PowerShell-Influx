Function ConvertTo-UnixTimeMillisecond {
    <#
        .SYNOPSIS
            Converts a datetime string to a Unix time code in milliseconds.

        .DESCRIPTION
            This is the datetime format Influx expects by default for writing datetime fields.

        .PARAMETER Date
            The date/time to be converted.

        .EXAMPLE
            '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeMillisecond
            
            Result
            -----------
            1483274062120
    #>      
    [cmdletbinding()]
    [OutputType([double])]
    Param(
        [parameter(ValueFromPipeline)]
        $Date
    )
    Process {
        (New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End $Date).TotalMilliseconds
    }
}