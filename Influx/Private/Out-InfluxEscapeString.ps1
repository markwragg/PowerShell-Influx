Function Out-InfluxEscapeString { 
    <#
        .SYNOPSIS
            Escapes the Influx REST API illegal characters using '\', several options are available based on the influx object to escape (measurement, field name, field value, etc)

        .DESCRIPTION
            Used in the Write-Influx function to escape measurement, tag and metric names and values before submitting them to the REST API.

        .PARAMETER String
            The string to be escaped.

        .PARAMETER StringType
            The influx object to be escaped: Measurement / FieldTextValue / Other. if not specified defaults to "Other"

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
        $String,
        [parameter()]
        [ValidateSet("Measurement","FieldTextValue","Other")]
        [string]
        $StringType
    )
    process {
        Switch ($StringType) {
            "Measurement" { $String -Replace '(\s|,|\\)', '\$1' }
            "FieldTextValue" { $String -Replace '("|\\)', '\$1' }
            "Other" { $String -Replace '(\s|=|,|\\|")', '\$1' }
            default { $String -Replace '(\s|=|,|\\|")', '\$1' }
        }
    }
}