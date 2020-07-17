# Send-3ParSystemMetric

## SYNOPSIS
Sends 3Par System metrics to Influx.

## SYNTAX

```
Send-3ParSystemMetric [[-Measure] <String>] [[-Tags] <String[]>] [-SANIPAddress] <String>
 [-SANUserName] <String> [-SANPwdFile] <String> [[-Database] <String>] [[-Server] <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function requires the HPE3PARPSToolkit module from HP.

## EXAMPLES

### EXAMPLE 1
```
Send-3ParSystemMetric -Measure 'Test3PAR' -Tags System_Name,System_Model,System_ID -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
```

Description
-----------
This command will submit the specified tags and 3PAR metrics to a measure called 'Test3PAR'.

## PARAMETERS

### -Measure
The name of the measure to be updated or created.

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

### -Database
The name of the Influx database to write to.
Default: 'storage'.
This must exist in Influx!

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Storage
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
Position: 7
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
