Function Send-DatastoreMetric {
    <#
        .SYNOPSIS
            Sends Datastore metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all Datastores returned by Get-Datastore.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of datastore tags to be included. Default: 'Name','ParentFolder','Type'

        .PARAMETER Datastore
            One or more datastores to be queried.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-DatastoreMetric -Measure 'TestDatastores' -Tags Name,Type -Datastore Test*
            
            Description
            -----------
            This command will submit the specified tags and datastore metrics to a measure called 'TestDatastores' for all datastores starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = 'Datastore',

        [String[]]
        $Tags = ('Name', 'ParentFolder', 'Type'),

        [String[]]
        $Datastore = '*',

        [string]
        $Database = 'vmware',
        
        [string]
        $Server = 'http://localhost:8086'
    )

    $MetricParams = @{
        Measure   = $Measure
        Tags      = $Tags
        Datastore = $Datastore
    }

    $Metric = Get-DatastoreMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}