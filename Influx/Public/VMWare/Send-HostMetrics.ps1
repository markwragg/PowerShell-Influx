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

        .EXAMPLE
            Send-HostMetrics -Measure 'TestESXHosts' -Tags Name,Parent -Hosts TestHost*
            
            Description
            -----------
            This command will submit the specified tag and common ESX host data to a measure called 'TestESXHosts' for all hosts starting with 'TestHost'
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        $Measure = 'ESXHost',

        $Tags = ('Name','Parent','State','PowerState','Version'),

        $Hosts = '*'
    )

    Write-Verbose 'Getting hosts..'
    $Hosts = Get-VMHost $Hosts

    Write-Verbose 'Getting host statistics..'
    $Stats = $Hosts | Get-Stat -MaxSamples 1 -Common | Where {-not $_.Instance}

    foreach ($Host in $Hosts) {
        
        $TagData = @{}
        ($Host | Select Name,$Tags).PSObject.Properties | ForEach-Object { $TagData.Add($_.Name,$_.Value) }

        $Metrics = @{}
        $Stats | Where-Object { $_.Entity.Name -eq $Host.Name } | ForEach-Object { $Metrics.Add($_.MetricId,$_.Value) }

        Write-Verbose "Sending data for $($Host.Name) to Influx.."
        Write-Verbose $TagData
        Write-Verbose $Metrics

        if ($PSCmdlet.ShouldProcess($Host.name)) {
            Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics
        }
    }
}