Function Send-ResourcePoolMetric {
    <#
        .SYNOPSIS
            Sends Resource Pool metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all Resource Pool returned by Get-ResourcePool.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of Resource Pool tags to be included. Default: 'Name','Parent'

        .PARAMETER ResourcePool
            One or more Resource Pools to be queried.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-ResourcePoolMetric -Measure 'TestResources' -Tags Name,NumCpuShares -ResourcePool Test*
            
            Description
            -----------
            This command will submit the specified tags and resource pool metrics to a measure called 'TestResources' for all resource pools starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = 'ResourcePool',

        [String[]]
        $Tags = ('Name', 'Parent'),

        [String[]]
        $ResourcePool = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    $MetricParams = @{
        Measure      = $Measure
        Tags         = $Tags
        ResourcePool = $ResourcePool
    }

    $Metric = Get-ResourcePoolMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}