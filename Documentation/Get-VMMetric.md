# Get-VMMetric

## SYNOPSIS
Returns Virtual Machine metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-VMMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-VMs] <String[]>] [-Stats] [<CommonParameters>]
```

## DESCRIPTION
By default this cmdlet returns metrics for all Virtual Machines returned by Get-VM.

## EXAMPLES

### EXAMPLE 1
```
Get-VMMetric -Measure 'TestVirtualMachines' -Tags Name,ResourcePool -Hosts TestVM*
```

Description
-----------
This command will return the specified tag and common VM host data for a measure called 'TestVirtualMachines' for all VMs starting with 'TestVM'

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
