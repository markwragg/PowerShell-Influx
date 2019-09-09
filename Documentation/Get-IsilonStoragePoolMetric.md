# Get-IsilonStoragePoolMetric

## SYNOPSIS
Returns Isilon Storage Pool usage metrics returned by the Get-isiStoragepools cmdlet as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-IsilonStoragePoolMetric [[-Measure] <String>] [-IsilonName] <String> [-IsilonPwdFile] <String>
 [-ClusterName] <String> [<CommonParameters>]
```

## DESCRIPTION
This function requires the IsilonPlatform module from the PSGallery.

## EXAMPLES

### EXAMPLE 1
```
Get-IsilonStoragePoolMetric -Measure 'TestIsilonSP' -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
```

Description
-----------
This command will return a PowerShell object with the specified Isilon's Storage Pool metrics for a measure called 'TestIsilonSP'.

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
