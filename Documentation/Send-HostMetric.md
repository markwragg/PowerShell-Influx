# Send-HostMetric

## SYNOPSIS
Sends common ESX Host metrics to Influx.

## SYNTAX

```
Send-HostMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-Hosts] <String[]>] [-Stats]
 [[-Database] <String>] [[-Server] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet sends metrics for all ESX hosts returned by Get-VMHost.

## EXAMPLES

### EXAMPLE 1
```
Send-HostMetric -Measure 'TestESXHosts' -Tags Name,Parent -Hosts TestHost*
```

Description
-----------
This command will submit the specified tag and common ESX host data to a measure called 'TestESXHosts' for all hosts starting with 'TestHost'

## PARAMETERS

### -Measure
The name of the measure to be updated or created.

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

### -Database
The name of the Influx database to write to.
Default: 'vmware'.
This must exist in Influx!

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Vmware
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
The URL and port for the Influx REST API.
Default: 'http://localhost:8086'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Http://localhost:8086
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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
