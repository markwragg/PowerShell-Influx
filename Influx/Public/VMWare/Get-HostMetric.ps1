Function Get-HostMetric {
    <#
        .SYNOPSIS
            Returns common ESX Host metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            By default this cmdlet returns metrics for all ESX hosts returned by Get-VMHost.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of host tags to be included. Default: 'Name','Parent','State','PowerState','Version'

        .PARAMETER Hosts
            One or more hosts to be queried.

        .PARAMETER Stats
            Use this switch if you want to collect common host stats using Get-Stat.
    
        .EXAMPLE
            Get-HostMetric -Measure 'TestESXHosts' -Tags Name,Parent -Hosts TestHost*
            
            Description
            -----------
            This command will return the specified tag and common ESX host data for a measure called 'TestESXHosts' for all hosts starting with 'TestHost'
    #>  
    [cmdletbinding()]
    param(
        [String]
        $Measure = 'ESXHost',

        [String[]]
        $Tags = ('Name', 'Parent', 'State', 'PowerState', 'Version'),

        [String[]]
        $Hosts = '*',

        [Switch]
        $Stats
    )

    Write-Verbose 'Getting hosts..'
    $VMHosts = Get-VMHost $Hosts

    if ($VMHosts) {

        if ($Stats) {
            Write-Verbose 'Getting host statistics..'
            $HostStats = $VMHosts | Get-Stat -MaxSamples 1 -Common | Where-Object {-not $_.Instance}
        }

        foreach ($VMHost in $VMHosts) {
        
            $TagData = @{}
            ($VMHost | Select-Object $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value) 
                }
            }

            $Metrics = @{
                CpuTotalMhz        = $VMHost.CpuTotalMhz
                CpuUsageMhz        = $VMHost.CpuUsageMhz
                CpuUsagePercent    = (($VMHost.CpuUsageMhz / $VMHost.CpuTotalMhz) * 100)
                MemoryTotalGB      = $VMHost.MemoryTotalGB
                MemoryUsageGB      = $VMHost.MemoryUsageGB
                MemoryUsagePercent = (($VMHost.MemoryUsageGB / $VMHost.MemoryTotalGB) * 100)
            }
            
            if ($HostStats) {
                $HostStats | Where-Object { $_.Entity.Name -eq $VMHost.Name } | ForEach-Object { $Metrics.Add($_.MetricId, $_.Value) }
            }

            [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = $Measure
                Tags       = $TagData
                Metrics    = $Metrics
            }
        }
    }
}