# Get-DatastoreMetric

## SYNOPSIS
Returns Datastore metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-DatastoreMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-Datastore] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet returns metrics for all Datastores returned by Get-Datastore.

## EXAMPLES

### EXAMPLE 1
```
Send-DatastoreMetric -Measure 'TestDatastores' -Tags Name,Type -Datastore Test*
```

Description
-----------
This command will submit the specified tags and datastore metrics to a measure called 'TestDatastores' for all datastores starting with 'Test'

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Datastore
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of datastore tags to be included.
Default: 'Name','ParentFolder','Type'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('Name', 'ParentFolder', 'Type')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Datastore
One or more datastores to be queried.

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

### -ProgressAction
{{Fill ProgressAction Description}}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
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
