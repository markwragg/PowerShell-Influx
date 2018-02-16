Function ConvertTo-StatsDString {
    <#
        .SYNOPSIS
            Converts a metric object to a StatsD format string which could be used with Write-StatsD.

        .DESCRIPTION
            This is the format a StatsD listener expects for writing metrics.

        .PARAMETER InputObject
            The metric object to be converted.

        .PARAMETER Type
            The type of StatsD metric. Default: g (gauge: will record whatever exact value is included with each metric provided). 
            See Statsd documentation for explanations of the different metric types accepted.

        .EXAMPLE
            Get-HostMetric -Hosts somehost1 -Tags Name,PowerState | ConvertTo-StatsDString
            
            Result
            -------------------
            CpuUsageMhz,Name=somehost1,PowerState=PoweredOn:305|g
            MemoryUsageGB,Name=somehost1,PowerState=PoweredOn:17.0029296875|g
    #>      
    [cmdletbinding()]
    [OutputType([String])]
    Param(
        [Parameter(ValueFromPipeline = $True, Position = 0)]
        [PSTypeName('Metric')]
        $InputObject,

        [string]
        $Type = 'g'
    )
    Process {
        $InputObject | ForEach-Object {
            
            $Tags = @()
            ForEach ($Tag in $_.Tags.GetEnumerator() | Sort-Object Key) {
                $Tags += "$($Tag.Key)=$($Tag.Value)"
            }
            
            $TagData = ',' + ($Tags -Join ',')
            
            ForEach ($Metric in $_.Metrics.GetEnumerator() | Sort-Object Key) {
                "$($_.Measure).$($Metric.Key)$TagData`:$($Metric.Value)|$Type"
            }
        }
    }
}