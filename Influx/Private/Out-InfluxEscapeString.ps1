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
        # Backslashes are not escaped for Measurement/Other: InfluxDB line protocol does not treat '\' as
        # a reserved character outside of quoted field values, and escaping it here would corrupt values
        # such as Windows paths (e.g. 'C:\' becoming 'C:\\').
        if ($StringType -ne 'FieldTextValue' -and $String -match '\\$') {
            Write-Warning "'$String' ends with a backslash. InfluxDB line protocol cannot parse a measurement, tag key/value or field key ending in a backslash and will reject the write; consider removing or replacing the trailing backslash."
        }

        Switch ($StringType) {
            # Measurement names only need whitespace and commas escaped; there's no key=value structure to protect.
            "Measurement" { $String -Replace '(\s|,)', '\$1' }
            # Field text values are wrapped in "..." so the characters that would break out of the quotes need escaping.
            "FieldTextValue" { $String -Replace '("|\\)', '\$1' }
            # Tag keys/values and field keys are part of key=value,key=value pairs, so = and , are structural and must be escaped, along with whitespace.
            "Other" { $String -Replace '(\s|=|,)', '\$1' }
            # No -StringType specified: treat the same as "Other".
            default { $String -Replace '(\s|=|,)', '\$1' }
        }
    }
}