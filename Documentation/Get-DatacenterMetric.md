# Get-DatacenterMetric

## SYNOPSIS
Returns VMWare Datacenter metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-DatacenterMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-Datacenter] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet returns metrics for all Datacenters returned by Get-Datacenter.

## EXAMPLES

### EXAMPLE 1
```
Get-DatacenterMetric -Measure 'TestDatacenter' -Tags Name,NumCpuShares -Datacenter Test*
```

Description
-----------
This command will return the specified tags and Datacenter metrics for a measure named 'TestDatacenter' for all Datacenters starting with 'Test'

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Datacenter
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of Datacenter tags to be included.
Default: 'Name','ParentFolder'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('Name', 'ParentFolder')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Datacenter
One or more Datacenters to be queried.

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
