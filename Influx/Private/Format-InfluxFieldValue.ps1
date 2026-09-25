Function Format-InfluxFieldValue {
    <#
        .SYNOPSIS
            Formats a raw metric value as an Influx Line Protocol field value.

        .DESCRIPTION
            Used by Write-Influx, Write-InfluxUDP and ConvertTo-InfluxLineString to format a metric value ready for
            inclusion in a line protocol string: numeric and boolean values are passed through unescaped, [datetime]
            values are converted to a Unix nanosecond integer field (Influx has no native date/time field type), and
            everything else is quoted and escaped as a text field value.

        .PARAMETER Value
            The raw metric value to format.

        .EXAMPLE
            (Get-Date) | Format-InfluxFieldValue

        .EXAMPLE
            100 | Format-InfluxFieldValue
    #>
    [cmdletbinding()]
    [OutputType([string])]
    param(
        [parameter(ValueFromPipeline)]
        $Value
    )
    process {
        if ($Value -is [datetime]) {
            # Influx has no date/time field type, so store it as nanoseconds since the Unix epoch (the same
            # precision Influx itself uses for the line's timestamp) rather than a culture-dependent ToString().
            "$($Value | ConvertTo-UnixTimeNanosecond)i"
        }
        elseif ($Value -isnot [ValueType]) {
            if ($null -ne $Value -and $Value -isnot [string] -and $Value.GetType().GetMethod('ToString', [Type]::EmptyTypes).DeclaringType -eq [object]) {
                Write-Warning "Metric value of type [$($Value.GetType().FullName)] has no meaningful ToString() representation and will be written as the literal string '$Value'. Convert it to a suitable value (e.g. a specific property) before passing it to this function."
            }
            '"' + ($Value | Out-InfluxEscapeString -StringType FieldTextValue) + '"'
        }
        else {
            $Value
        }
    }
}
