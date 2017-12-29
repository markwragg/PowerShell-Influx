Function Send-HostMetrics {
    <#
        .SYNOPSIS
            Sends common ESX Host metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all ESX hosts returned by Get-VMHost.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of host tags to be included. Default: 'Name','Parent','State','PowerState','Version'

        .PARAMETER Hosts
            One or more hosts to be queried.

        .PARAMETER Stats
            Use this switch if you want to collect common host stats using Get-Stat.
        
        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-HostMetrics -Measure 'TestESXHosts' -Tags Name,Parent -Hosts TestHost*
            
            Description
            -----------
            This command will submit the specified tag and common ESX host data to a measure called 'TestESXHosts' for all hosts starting with 'TestHost'
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'ESXHost',

        [String[]]
        $Tags = ('Name','Parent','State','PowerState','Version'),

        [String[]]
        $Hosts = '*',

        [Switch]
        $Stats,

        [string]
        $Database ='vmware',
        
        [string]
        $Server = 'http://localhost:8086'
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
                    $TagData.Add($_.Name,$_.Value) 
                }
            }

            $Metrics = @{
                CpuTotalMhz = $VMHost.CpuTotalMhz
                CpuUsageMhz = $VMHost.CpuUsageMhz
                CpuUsagePercent = (($VMHost.CpuUsageMhz / $VMHost.CpuTotalMhz) * 100)
                MemoryTotalGB = $VMHost.MemoryTotalGB
                MemoryUsageGB = $VMHost.MemoryUsageGB
                MemoryUsagePercent = (($VMHost.MemoryUsageGB / $VMHost.MemoryTotalGB) * 100)
            }
            
            if ($HostStats) {
                $HostStats | Where-Object { $_.Entity.Name -eq $VMHost.Name } | ForEach-Object { $Metrics.Add($_.MetricId,$_.Value) }
            }

            Write-Verbose "Sending data for $($VMHost.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($VMHost.name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
            }
        }

    }else{
        Throw 'No host data returned'
    }
}