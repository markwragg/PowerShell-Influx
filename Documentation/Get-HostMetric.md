# Get-HostMetric

## SYNOPSIS
Returns common ESX Host metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-HostMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-Hosts] <String[]>] [-Stats] [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet returns metrics for all ESX hosts returned by Get-VMHost.

## EXAMPLES

### EXAMPLE 1
```
Get-HostMetric -Measure 'TestESXHosts' -Tags Name,Parent -Hosts TestHost*
```

Description
-----------
This command will return the specified tag and common ESX host data for a measure called 'TestESXHosts' for all hosts starting with 'TestHost'

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: ESXHost
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of host tags to be included.
Default: 'Name','Parent','State','PowerState','Version'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('Name', 'Parent', 'State', 'PowerState', 'Version')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hosts
One or more hosts to be queried.

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

### -Stats
Use this switch if you want to collect common host stats using Get-Stat.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
