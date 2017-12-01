Function Send-DatastoreClusterMetrics {
    <#
        .SYNOPSIS
            Sends Datastore Cluster metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all Datastore Clusters returned by Get-DatastoreCluster.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of Datastore Cluster tags to be included. Default: 'Name'

        .PARAMETER DatastoreCluster
            One or more Datastore Clusters to be queried.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-VMMetrics -Measure 'TestDatastoreClusters' -Tags Name,Type -DatastoreCluster Test*
            
            Description
            -----------
            This command will submit the specified tags and DatastoreCluster metrics to a measure called 'TestDatastoreClusters' for all DatastoreClusters starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'DatastoreCluster',

        [String[]]
        $Tags = ('Name'),

        [String[]]
        $DatastoreCluster = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    Write-Verbose 'Getting DatastoreClusters..'
    $DatastoreClusters = Get-DatastoreCluster $DatastoreCluster

    if ($DatastoreClusters) {
        
        foreach ($DSCluster in $DatastoreClusters) {
        
            $TagData = @{}
            ($DSCluster | Select $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name,$_.Value) 
                }
            }

            $Metrics = @{
                CapacityGB = $DSCluster.CapacityGB
                FreeSpaceGB = $DSCluster.FreeSpaceGB
                UsedSpaceGB = ($DSCluster.CapacityGB - $DSCluster.FreeSpaceGB)
            }
            
            Write-Verbose "Sending data for $($DSCluster.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($DSCluster.name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
            }
        }

    }else{
        Throw 'No DatastoreCluster data returned'
    }
}