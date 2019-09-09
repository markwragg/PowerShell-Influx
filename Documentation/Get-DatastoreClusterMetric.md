# Get-DatastoreClusterMetric

## SYNOPSIS
Returns Datastore Cluster metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-DatastoreClusterMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-DatastoreCluster] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet returns metrics for all Datastore Clusters returned by Get-DatastoreCluster.

## EXAMPLES

### EXAMPLE 1
```
Get-DatastoreClusterMetric -Measure 'TestDatastoreClusters' -Tags Name,Type -DatastoreCluster Test*
```

Description
-----------
This command will return the specified tags and DatastoreCluster metrics for a measure called 'TestDatastoreClusters' for all DatastoreClusters starting with 'Test'.

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: DatastoreCluster
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of Datastore Cluster tags to be included.
Default: 'Name'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Name
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatastoreCluster
One or more Datastore Clusters to be queried.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
