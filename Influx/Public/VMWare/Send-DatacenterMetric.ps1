Function Send-DatacenterMetric {
    <#
        .SYNOPSIS
            Sends Datacenter metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all Datacenter returned by Get-Datacenter.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of Datacenter tags to be included. Default: 'Name','ParentFolder'

        .PARAMETER Datacenter
            One or more Datacenters to be queried.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-DatacenterMetric -Measure 'TestDatacenter' -Tags Name,NumCpuShares -Datacenter Test*
            
            Description
            -----------
            This command will submit the specified tags and Datacenter metrics to a measure called 'TestDatacenter' for all Datacenters starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = 'Datacenter',

        [String[]]
        $Tags = ('Name', 'ParentFolder'),

        [String[]]
        $Datacenter = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    $MetricParams = @{
        Measure    = $Measure
        Tags       = $Tags
        Datacenter = $Datacenter
    }

    $Metric = Get-DatacenterMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}