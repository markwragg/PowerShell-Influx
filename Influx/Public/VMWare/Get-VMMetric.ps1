Function Get-VMMetric {
    <#
        .SYNOPSIS
            Returns Virtual Machine metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            By default this cmdlet returns metrics for all Virtual Machines returned by Get-VM.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of virtual machine tags to be included. Default: 'Name','Folder','ResourcePool','PowerState','Guest','VMHost'

        .PARAMETER VMs
            One or more Virtual Machines to be queried.

        .PARAMETER Stats
            Use to enable the collection of VM statistics via Get-Stat for each VM.

        .EXAMPLE
            Get-VMMetric -Measure 'TestVirtualMachines' -Tags Name,ResourcePool -Hosts TestVM*
            
            Description
            -----------
            This command will return the specified tag and common VM host data for a measure called 'TestVirtualMachines' for all VMs starting with 'TestVM'
    #>  
    [cmdletbinding()]
    param(
        [string]
        $Measure = 'VirtualMachine',

        [string[]]
        $Tags = ('Name', 'Folder', 'ResourcePool', 'PowerState', 'Guest', 'VMHost'),

        [string[]]
        $VMs = '*',

        [switch]
        $Stats
    )

    Write-Verbose 'Getting VMs..'
    $VMServers = Get-VM $VMs

    if ($VMServers) {
        
        if ($Stats) {
            Write-Verbose 'Getting VM statistics..'
            $VMStats = $VMServers | Get-Stat -MaxSamples 1 -Common | Where-Object {-not $_.Instance}
        }

        foreach ($VM in $VMServers) {
        
            $TagData = @{}
            ($VM | Select-Object $Tags).PSObject.Properties | ForEach-Object {     
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value) 
                }
            }

            $Metrics = @{
                PowerState           = [int]$VM.PowerState
                GuestHeartbeatStatus = [int]$VM.ExtensionData.Summary.QuickStats.GuestHeartbeatStatus
            }

            $QuickStats = $VM.ExtensionData.Summary.QuickStats | Select-Object OverallCpuUsage, GuestMemoryUsage, HostMemoryUsage, UptimeSeconds
            
            $QuickStats.PSObject.Properties | ForEach-Object {     
                if ($_.Value) {
                    $Metrics.Add($_.Name, $_.Value) 
                }
            }

            if ($VMStats) {
                $VMStats | Where-Object { $_.Entity.Name -eq $VM.Name } | ForEach-Object { $Metrics.Add($_.MetricId, $_.Value) }
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