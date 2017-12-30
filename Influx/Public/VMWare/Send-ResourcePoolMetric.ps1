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
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'ResourcePool',

        [String[]]
        $Tags = ('Name','Parent'),

        [String[]]
        $ResourcePool = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    Write-Verbose 'Getting resource pools..'
    $ResourcePools = Get-ResourcePool $ResourcePool

    if ($ResourcePools) {
        
        foreach ($RP in $ResourcePools) {
        
            $TagData = @{}
            ($RP | Select-Object $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name,$_.Value) 
                }
            }

            $VMs = $RP | Get-VM

            $Metrics = @{ VMs_Count = $VMs.count }

            If ($VMs.count -gt 0) {
                $Metrics.Add('VMs_MemoryGB_Total',($VMs | Measure-Object MemoryGB -Sum).Sum)
                $Metrics.Add('VMs_NumCPU_Total',($VMs | Measure-Object NumCPU -Sum).Sum)
            }
            
            $VMS | Group-Object PowerState | ForEach-Object { 
                $Metrics.Add("$($_.Name)_VMs_Count",$_.Count)
                If ($_.count -gt 0) {
                    $Metrics.Add("$($_.Name)_VMs_MemoryGB_Total",($_.Group | Measure-Object MemoryGB -Sum).Sum) 
                    $Metrics.Add("$($_.Name)_VMs_NumCPU_Total",($_.Group | Measure-Object NumCPU -Sum).Sum) 
                }
            }
            
            Write-Verbose "Sending data for $($RP.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($RP.name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
            }
        }

    }else{
        Throw 'No resource pool data returned'
    }
}