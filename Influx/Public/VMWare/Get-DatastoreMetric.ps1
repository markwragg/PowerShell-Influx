Function Get-DatastoreMetric {
    <#
        .SYNOPSIS
            Returns Datastore metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            By default this cmdlet returns metrics for all Datastores returned by Get-Datastore.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

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
    [cmdletbinding()]
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

    Write-Verbose 'Getting datastores..'
    $Datastores = Get-Datastore $Datastore

    if ($Datastores) {
        
        foreach ($DS in $Datastores) {
        
            $TagData = @{}
            ($DS | Select-Object $Tags).PSObject.Properties | ForEach-Object { 
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value) 
                }
            }
            
            [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = $Measure
                Tags       = $TagData
                Metrics    = @{
                    CapacityGB  = $DS.CapacityGB
                    FreeSpaceGB = $DS.FreeSpaceGB
                    UsedSpaceGB = ($DS.CapacityGB - $DS.FreeSpaceGB)
                }
            }
        }
    }
    else {
        Write-Verbose 'No datastore data returned'
    }
}