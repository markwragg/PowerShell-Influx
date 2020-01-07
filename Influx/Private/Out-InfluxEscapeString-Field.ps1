Function Out-InfluxEscapeString-Field { 
    <#
        .SYNOPSIS
            Escapes the Influx REST API illegal characters in string Fields/Metric values '"' by adding a '\' before them. (This rule applies only to values and not to keys)

        .DESCRIPTION
            Used in the Write-Influx function to escape Fields/Metric values string submitting them to the REST API. (This rule applies only to values and not to keys)

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