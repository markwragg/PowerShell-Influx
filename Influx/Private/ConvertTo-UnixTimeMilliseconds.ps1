Function ConvertTo-UnixTimeMilliseconds {
    <#
        .SYNOPSIS
            Converts a datetime string to a Unix time code in milliseconds.

        .DESCRIPTION
            This is the datetime format Influx expects by default for writing datetime fields.

        .PARAMETER Date
            The date/time to be converted.

        .EXAMPLE
            '20-10-2017 12:34:22.12' | ConvertTo-UnixTimeMilliseconds
            
            Result
            -----------
            1508502862120
    #>      
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType([double])]
    Param(
        [parameter(ValueFromPipeline)]
        $Date
    )
    Process {
        if ($PSCmdlet.ShouldProcess($Date)) {
            (New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End $Date).TotalMilliseconds
        }
    }
}