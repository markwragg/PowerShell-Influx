# ConvertTo-StatsDString

## SYNOPSIS
Converts a metric object to a StatsD format string which could be used with Write-StatsD.

## SYNTAX

```
ConvertTo-StatsDString [[-InputObject] <Object>] [-Type <String>] [<CommonParameters>]
```

## DESCRIPTION
This is the format a StatsD listener expects for writing metrics.

## EXAMPLES

### EXAMPLE 1
```
Get-HostMetric -Hosts somehost1 -Tags Name,PowerState | ConvertTo-StatsDString
```

Result
-------------------
CpuUsageMhz,Name=somehost1,PowerState=PoweredOn:305|g
MemoryUsageGB,Name=somehost1,PowerState=PoweredOn:17.0029296875|g

## PARAMETERS

### -InputObject
The metric object to be converted.

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

### -Type
The type of StatsD metric.
Default: g (gauge: will record whatever exact value is included with each metric provided). 
See Statsd documentation for explanations of the different metric types accepted.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: G
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
