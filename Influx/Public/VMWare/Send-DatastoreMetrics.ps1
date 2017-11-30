Function Send-DatastoreMetrics {
    <#
        .SYNOPSIS
            Sends Datastore metrics to Influx.

        .DESCRIPTION
            By default this cmdlet sends metrics for all Datastores returned by Get-Datastore.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of datastore tags to be included. Default: 'Name','Folder','ResourcePool','PowerState','Guest','VMHost'

        .PARAMETER Datastore
            One or more datastores to be queried.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'vmware'. This must exist in Influx!

        .EXAMPLE
            Send-VMMetrics -Measure 'TestDatastores' -Tags Name,Type -Datastore Test*
            
            Description
            -----------
            This command will submit the specified tags and datastore metrics to a measure called 'TestDatastores' for all datastores starting with 'Test'
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'Datastore',

        [String[]]
        $Tags = ('Name','ParentFolder','Type'),

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
            ($VM | Select $Tags).PSObject.Properties | ForEach-Object { $TagData.Add($_.Name,$_.Value) }

            $Metrics = @{
                State = $DS.State
                CapacityGB = $DS.CapacityGB
                FreeSpaceGB = $DS.FreeSpaceGB
                UsedSpaceGB = ($DS.CapacityGB - $DS.FreeSpaceGB)
            }
            
            Write-Verbose "Sending data for $($DS.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($DS.name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
            }
        }

    }else{
        Throw 'No datastore data returned'
    }
}