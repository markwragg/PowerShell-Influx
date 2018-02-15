Function Get-DatastoreClusterMetric {
    <#
        .SYNOPSIS
            Returns Datastore Cluster metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            By default this cmdlet returns metrics for all Datastore Clusters returned by Get-DatastoreCluster.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of Datastore Cluster tags to be included. Default: 'Name'

        .PARAMETER DatastoreCluster
            One or more Datastore Clusters to be queried.

        .EXAMPLE
            Get-DatastoreClusterMetric -Measure 'TestDatastoreClusters' -Tags Name,Type -DatastoreCluster Test*
            
            Description
            -----------
            This command will return the specified tags and DatastoreCluster metrics for a measure called 'TestDatastoreClusters' for all DatastoreClusters starting with 'Test'.
    #>  
    [cmdletbinding()]
    param(
        [String]
        $Measure = 'DatastoreCluster',

        [String[]]
        $Tags = 'Name',

        [String[]]
        $DatastoreCluster = '*'
    )

    Write-Verbose 'Getting DatastoreClusters..'
    $DatastoreClusters = Get-DatastoreCluster $DatastoreCluster

    if ($DatastoreClusters) {
        
        foreach ($DSCluster in $DatastoreClusters) {
        
            $TagData = @{}
            ($DSCluster | Select-Object $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value) 
                }
            }
            
            [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = $Measure
                Tags       = $TagData
                Metrics    = @{
                    CapacityGB       = $DSCluster.CapacityGB
                    FreeSpaceGB      = $DSCluster.FreeSpaceGB
                    UsedSpaceGB      = ($DSCluster.CapacityGB - $DSCluster.FreeSpaceGB)
                    UsedSpacePercent = (($DSCluster.CapacityGB - $DSCluster.FreeSpaceGB) / $DSCluster.CapacityGB * 100)
                }
            }
        }
    }
    else {
        Write-Verbose 'No DatastoreCluster data returned'
    }
}