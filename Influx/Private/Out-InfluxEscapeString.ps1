Function Out-InfluxEscapeString { 
    <#
        .SYNOPSIS
            Escapes the Influx REST API illegal characters ' ','=' and ',' by adding a '\' before them.

        .DESCRIPTION
            Used in the Write-Influx function to escape tag and metric name and values before submitting them to the REST API.

        .PARAMETER String
            The string to be escaped.

        .EXAMPLE
            'Some ,string=' | Out-InfluxEscapeString
            
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
        $String -Replace '(\s|\=|,)', '\$1'
    }
}