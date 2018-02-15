Function Get-ResourcePoolMetric {
    <#
        .SYNOPSIS
            Returns Resource Pool metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            By default this cmdlet returns metrics for all Resource Pools returned by Get-ResourcePool.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of Resource Pool tags to be included. Default: 'Name','Parent'

        .PARAMETER ResourcePool
            One or more Resource Pools to be queried.

        .EXAMPLE
            Get-ResourcePoolMetric -Measure 'TestResources' -Tags Name,NumCpuShares -ResourcePool Test*
            
            Description
            -----------
            This command will return the specified tags and resource pool metrics for a measure called 'TestResources' for all resource pools starting with 'Test'
    #>  
    [cmdletbinding()]
    param(
        [String]
        $Measure = 'ResourcePool',

        [String[]]
        $Tags = ('Name', 'Parent'),

        [String[]]
        $ResourcePool = '*'
    )

    Write-Verbose 'Getting resource pools..'
    $ResourcePools = Get-ResourcePool $ResourcePool

    if ($ResourcePools) {
        
        foreach ($RP in $ResourcePools) {
        
            $TagData = @{}
            ($RP | Select-Object $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value) 
                }
            }

            $VMs = $RP | Get-VM

            $Metrics = @{ VMs_Count = $VMs.count }

            If ($VMs.count -gt 0) {
                $Metrics.Add('VMs_MemoryGB_Total', ($VMs | Measure-Object MemoryGB -Sum).Sum)
                $Metrics.Add('VMs_NumCPU_Total', ($VMs | Measure-Object NumCPU -Sum).Sum)
            }
            
            $VMS | Group-Object PowerState | ForEach-Object { 
                $Metrics.Add("$($_.Name)_VMs_Count", $_.Count)
                If ($_.count -gt 0) {
                    $Metrics.Add("$($_.Name)_VMs_MemoryGB_Total", ($_.Group | Measure-Object MemoryGB -Sum).Sum) 
                    $Metrics.Add("$($_.Name)_VMs_NumCPU_Total", ($_.Group | Measure-Object NumCPU -Sum).Sum) 
                }
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