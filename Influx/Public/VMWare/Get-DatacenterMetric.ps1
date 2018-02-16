Function Get-DatacenterMetric {
    <#
        .SYNOPSIS
            Returns VMWare Datacenter metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            By default this cmdlet returns metrics for all Datacenters returned by Get-Datacenter.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of Datacenter tags to be included. Default: 'Name','ParentFolder'

        .PARAMETER Datacenter
            One or more Datacenters to be queried.

        .EXAMPLE
            Get-DatacenterMetric -Measure 'TestDatacenter' -Tags Name,NumCpuShares -Datacenter Test*
            
            Description
            -----------
            This command will return the specified tags and Datacenter metrics for a measure named 'TestDatacenter' for all Datacenters starting with 'Test'
    #>  
    [cmdletbinding()]
    param(
        [String]
        $Measure = 'Datacenter',

        [String[]]
        $Tags = ('Name', 'ParentFolder'),

        [String[]]
        $Datacenter = '*'
    )

    Write-Verbose 'Getting Datacenters..'
    $Datacenters = Get-Datacenter $Datacenter

    if ($Datacenters) {
        
        foreach ($DC in $Datacenters) {
        
            $TagData = @{}
            ($DC | Select-Object $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value) 
                }
            }

            $VMs = $DC | Get-VM

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
    else {
        Write-Verbose 'No Datacenter data returned'
    }
}