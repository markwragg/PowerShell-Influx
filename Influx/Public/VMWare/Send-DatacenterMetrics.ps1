Function Send-DatacenterMetrics {
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
            Send-DatacenterMetrics -Measure 'TestDatacenter' -Tags Name,NumCpuShares -Datacenter Test*
            
            Description
            -----------
            This command will submit the specified tags and Datacenter metrics to a measure called 'TestDatacenter' for all Datacenters starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'Datacenter',

        [String[]]
        $Tags = ('Name','ParentFolder'),

        [String[]]
        $Datacenter = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    Write-Verbose 'Getting Datacenters..'
    $Datacenters = Get-Datacenter $Datacenter

    if ($Datacenters) {
        
        foreach ($DC in $Datacenters) {
        
            $TagData = @{}
            ($DC | Select $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name,$_.Value) 
                }
            }

            $VMs = $DC | Get-VM

            $Metrics = @{ VMs_Count = $VMs.count }

            If ($VMs.count -gt 0) {
                $Metrics.Add('VMs_MemoryGB_Total',($VMs | Measure MemoryGB -Sum).Sum)
                $Metrics.Add('VMs_NumCPU_Total',($VMs | Measure NumCPU -Sum).Sum)
            }
            
            $VMS | Group PowerState | ForEach-Object { 
                $Metrics.Add("$($_.Name)_VMs_Count",$_.Count)
                If ($_.count -gt 0) {
                    $Metrics.Add("$($_.Name)_VMs_MemoryGB_Total",($_.Group | Measure MemoryGB -Sum).Sum) 
                    $Metrics.Add("$($_.Name)_VMs_NumCPU_Total",($_.Group | Measure NumCPU -Sum).Sum) 
                }
            }
            
            Write-Verbose "Sending data for $($DC.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($DC.name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
            }
        }

    }else{
        Throw 'No Datacenter data returned'
    }
}