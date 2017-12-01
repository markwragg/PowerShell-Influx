Function Send-VMMetrics {
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

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-VMMetrics -Measure 'TestVirtualMachines' -Tags Name,ResourcePool -Hosts TestVM*
            
            Description
            -----------
            This command will submit the specified tag and common VM host data to a measure called 'TestVirtualMachines' for all VMs starting with 'TestVM'
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'VirtualMachine',

        [String[]]
        $Tags = ('Name','Folder','ResourcePool','PowerState','Guest','VMHost'),

        [String[]]
        $VMs = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    Write-Verbose 'Getting VMs..'
    $VMServers = Get-VM $VMs

    if ($VMServers) {
        
        if ($Stats) {
            Write-Verbose 'Getting VM statistics..'
            $VMStats = $VMServers | Get-Stat -MaxSamples 1 -Common | Where {-not $_.Instance}
        }

        foreach ($VM in $VMServers) {
        
            $TagData = @{}
            ($VM | Select $Tags).PSObject.Properties | ForEach-Object {     
                if ($_.Value) {
                    $TagData.Add($_.Name,$_.Value) 
                }
            }

            $Metrics = @{
                PowerState = '"' + $VM.PowerState + '"'
            }

            $QuickStats = $VM.ExtensionData.Summary.QuickStats | Select GuestHeartbeatStatus,OverallCpuUsage,GuestMemoryUsage,HostMemoryUsage,UptimeSeconds
            
            $QuickStats.PSObject.Properties | ForEach-Object {     
                if ($_.Value) {
                    $Metrics.Add($_.Name,$_.Value) 
                }
            }

            if ($VMStats) {
                $Stats | Where-Object { $_.Entity.Name -eq $VM.Name } | ForEach-Object { $Metrics.Add($_.MetricId,$_.Value) }
            }

            Write-Verbose "Sending data for $($VM.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($VM.name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
            }
        }
    }else{
        Throw 'No VM data returned'
    }
}