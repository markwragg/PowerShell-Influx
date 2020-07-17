# ConvertTo-Metric

## SYNOPSIS
Converts the specified properties of an object to a metric object, which can then be easily transmitted to Influx.

## SYNTAX

```
ConvertTo-Metric [[-InputObject] <Object>] -Measure <String> -MetricProperty <String[]>
 [-TagProperty <String[]>] [-Tags <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
Use to convert any PowerShell object in to a Metric object with specified Measure name, Metrics and Tags.
The metrics
are one or more named properties of the object.
The (optional) Tags can be one or more named properties of the object
and/or a provided hashtable of custom tags.

## EXAMPLES

### EXAMPLE 1
```
Get-Process | ConvertTo-Metric -Measure Processes -MetricProperty CPU -TagProperty Name,ID -Tags @{Host = $Env:ComputerName}
```

Description
-----------
This command will convert the specified object properties in to metrics and tags for a measure called 'Processes'.

## PARAMETERS

### -InputObject
The object that you want to convert to a metric object.
Can be provided via the pipeline.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Measure
The name of the measure to be updated or created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetricProperty
One or more strings which match property names of the Input Object that you want to convert to Metrics.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TagProperty
Optional: One or more strings which match property names of the Input Object, that you want to use as Tag data.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
Optional: A hashtable of custom tag names and values.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

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
