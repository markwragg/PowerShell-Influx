Function Send-HostMetric {
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
            Send-HostMetric -Measure 'TestESXHosts' -Tags Name,Parent -Hosts TestHost*
            
            Description
            -----------
            This command will submit the specified tag and common ESX host data to a measure called 'TestESXHosts' for all hosts starting with 'TestHost'
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = 'ESXHost',

        [String[]]
        $Tags = ('Name', 'Parent', 'State', 'PowerState', 'Version'),

        [String[]]
        $Hosts = '*',

        [Switch]
        $Stats,

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    $MetricParams = @{
        Measure = $Measure
        Tags    = $Tags
        Hosts   = $Hosts
        Stats   = $Stats
    }

    $Metric = Get-HostMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}