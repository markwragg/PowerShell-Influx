# Get-TFSBuildMetric

## SYNOPSIS
Returns TFS Build metrics as a metric object which can then be transmitted to Influx.

## SYNTAX

```
Get-TFSBuildMetric [[-Measure] <String>] [[-Tags] <String[]>] [[-Top] <Int32>] [-Latest] [-TFSRootURL] <String>
 [-TFSCollection] <String> [-TFSProject] <String> [<CommonParameters>]
```

## DESCRIPTION
This function requires the TFS module (install via Install-Module TFS).

## EXAMPLES

### EXAMPLE 1
```
Get-TFSBuildMetric -Measure 'TestTFS' -Tags Name,Author -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject
```

Description
-----------
This command will return the specified tags and build metrics of a measure called 'TestTFS' as a PowerShell object.

## PARAMETERS

### -Measure
The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: TFSBuild
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
An array of Build definition properties to be included, from those returned by Get-TfsBuildDefinitions.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ('Definition', 'Id', 'Result')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Top
An integer defining the number of most recent builds to return.
Default: 100.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -Latest
Switch parameter.
When used returns only the most recent build for each distinct definition.

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

### -TFSRootURL
The root URL for TFS, e.g https://yourserver.yoursite.com/TFS

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

### -TFSCollection
The name of the TFS collection to query.

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

### -TFSProject
The name of the TFS project to query.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
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
