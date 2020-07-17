# Send-IsilonStoragePoolMetric

## SYNOPSIS
Sends Isilon Storage Pool usage metrics returned by the Get-isiStoragepools cmdlet from the IsilonPlatform module to Influx.

## SYNTAX

```
Send-IsilonStoragePoolMetric [[-Measure] <String>] [-IsilonName] <String> [-IsilonPwdFile] <String>
 [-ClusterName] <String> [[-Database] <String>] [[-Server] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function requires the IsilonPlatform module from the PSGallery.

## EXAMPLES

### EXAMPLE 1
```
Send-IsilonStoragePoolMetric -Measure 'TestIsilonSP' -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
```

Description
-----------
This command will submit the specified Isilon's Storage Pool metrics to a measure called 'TestIsilonSP'.

## PARAMETERS

### -Measure
The name of the measure to be updated or created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: IsilonStoragePool
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsilonName
The name or IP address of the Isilon to be queried.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsilonPwdFile
The encrypted credentials file for connecting to the Isilon.
This should be created with Get-Credential | Export-Clixml.

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

### -ClusterName
A descriptive name for the Isilon Cluster.
This can be anything and is used for the Cluster tag field.

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

### -Database
The name of the Influx database to write to.
Default: 'storage'.
This must exist in Influx!

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
Position: 6
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
