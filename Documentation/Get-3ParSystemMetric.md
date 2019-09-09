# Get-3ParSystemMetric

## SYNOPSIS
Returns 3Par System metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-3ParSystemMetric [[-Measure] <String>] [[-Tags] <String[]>] [-SANIPAddress] <String>
 [-SANUserName] <String> [-SANPwdFile] <String> [<CommonParameters>]
```

## DESCRIPTION
This function requires the HPE3PARPSToolkit module from HP.

## EXAMPLES

### EXAMPLE 1
```
Get-3ParSystemMetric -Measure 'Test3PAR' -Tags System_Name,System_Model,System_ID -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
```

Description
-----------
This command will return a metric object with the specified tags and 3PAR metrics for a measure called 'Test3PAR'.

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 3PARSystem
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of 3PAR system tags to be included, from those returned by Get-3ParSystem.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('System_Name', 'System_Model')
Accept pipeline input: False
Accept wildcard characters: False
```

### -SANIPAddress
The IP address of the 3PAR SAN to be queried.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SANUserName
The username for connecting to the 3PAR.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SANPwdFile
The encrypted password file for connecting to the 3PAR.
This should be created with Set-3parPoshSshConnectionPasswordFile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
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
