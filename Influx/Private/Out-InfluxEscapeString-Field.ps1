Function Out-InfluxEscapeString-Field { 
    <#
        .SYNOPSIS
            Escapes the Influx REST API illegal characters in string Fields/Metric values '"' by adding a '\' before them.

        .DESCRIPTION
            Used in the Write-Influx function to escape only non-numeric data types values (strings) of and Fields/Metric before submitting them to the REST API. (This rule applies only to values and not to keys)

        .PARAMETER String
            The string to be escaped.

        .EXAMPLE
            'Some ,string=' | Out-InfluxEscapeString-Field
            
            Result
            -----------
            Some\ \,string\=
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param(
        [parameter(ValueFromPipeline)]
        [string]
        $String
    )
    process {
        $String -Replace '(")', '\$1'

    }
}