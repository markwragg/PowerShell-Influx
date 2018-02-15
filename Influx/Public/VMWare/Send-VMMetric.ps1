Function Send-VMMetric {
    <#
        .SYNOPSIS
            Sends Virtual Machine metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all Virtual Machines returned by Get-VM.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of virtual machine tags to be included. Default: 'Name','Folder','ResourcePool','PowerState','Guest','VMHost'

        .PARAMETER VMs
            One or more Virtual Machines to be queried.

        .PARAMETER Stats
            Use to enable the collection of VM statistics via Get-Stat for each VM.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-VMMetric -Measure 'TestVirtualMachines' -Tags Name,ResourcePool -Hosts TestVM*
            
            Description
            -----------
            This command will submit the specified tag and common VM host data to a measure called 'TestVirtualMachines' for all VMs starting with 'TestVM'
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [string]
        $Measure = 'VirtualMachine',

        [string[]]
        $Tags = ('Name', 'Folder', 'ResourcePool', 'PowerState', 'Guest', 'VMHost'),

        [string[]]
        $VMs = '*',

        [switch]
        $Stats,

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    $MetricParams = @{
        Measure = $Measure
        Tags    = $Tags
        VMs     = $VMs
        Stats   = $Stats
    }

    $Metric = Get-VMMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}