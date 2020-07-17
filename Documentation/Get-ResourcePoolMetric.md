# Get-ResourcePoolMetric

## SYNOPSIS
Returns Resource Pool metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-ResourcePoolMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-ResourcePool] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet returns metrics for all Resource Pools returned by Get-ResourcePool.

## EXAMPLES

### EXAMPLE 1
```
Get-ResourcePoolMetric -Measure 'TestResources' -Tags Name,NumCpuShares -ResourcePool Test*
```

Description
-----------
This command will return the specified tags and resource pool metrics for a measure called 'TestResources' for all resource pools starting with 'Test'

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ResourcePool
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of Resource Pool tags to be included.
Default: 'Name','Parent'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('Name', 'Parent')
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourcePool
One or more Resource Pools to be queried.

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
