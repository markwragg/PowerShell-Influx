Function Send-DatastoreClusterMetric {
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
            Send-DatastoreClusterMetric -Measure 'TestDatastoreClusters' -Tags Name,Type -DatastoreCluster Test*
            
            Description
            -----------
            This command will submit the specified tags and DatastoreCluster metrics to a measure called 'TestDatastoreClusters' for all DatastoreClusters starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = 'DatastoreCluster',

        [String[]]
        $Tags = 'Name',

        [String[]]
        $DatastoreCluster = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    $MetricParams = @{
        Measure          = $Measure
        Tags             = $Tags
        DatastoreCluster = $DatastoreCluster
    }

    $Metric = Get-DatastoreClusterMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}