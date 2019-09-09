# Send-VMMetric

## SYNOPSIS
Sends Virtual Machine metrics to Influx.

## SYNTAX

```
Send-VMMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-VMs] <String[]>] [-Stats] [[-Database] <String>]
 [[-Server] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet sends metrics for all Virtual Machines returned by Get-VM.

## EXAMPLES

### EXAMPLE 1
```
Send-VMMetric -Measure 'TestVirtualMachines' -Tags Name,ResourcePool -Hosts TestVM*
```

Description
-----------
This command will submit the specified tag and common VM host data to a measure called 'TestVirtualMachines' for all VMs starting with 'TestVM'

## PARAMETERS

### -Measure
The name of the measure to be updated or created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: VirtualMachine
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of virtual machine tags to be included.
Default: 'Name','Folder','ResourcePool','PowerState','Guest','VMHost'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('Name', 'Folder', 'ResourcePool', 'PowerState', 'Guest', 'VMHost')
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMs
One or more Virtual Machines to be queried.

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
Use to enable the collection of VM statistics via Get-Stat for each VM.

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
