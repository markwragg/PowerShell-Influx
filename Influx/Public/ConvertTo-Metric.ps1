Function ConvertTo-Metric {
    <#
        .SYNOPSIS
            Converts the specified properties of an object to a metric object, which can then be easily transmitted to Influx.

        .DESCRIPTION
            Use to convert any PowerShell object in to a Metric object with specified Measure name, Metrics and Tags. The metrics
            are one or more named properties of the object. The (optional) Tags can be one or more named properties of the object
            and/or a provided hashtable of custom tags.

        .PARAMETER InputObject
            The object that you want to convert to a metric object. Can be provided via the pipeline.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER MetricProperty
            One or more strings which match property names of the Input Object that you want to convert to Metrics.

        .PARAMETER TagProperty
            Optional: One or more strings which match property names of the Input Object, that you want to use as Tag data.

        .PARAMETER Tags
            Optional: A hashtable of custom tag names and values.

        .EXAMPLE
            Get-Process | ConvertTo-Metric -Measure Processes -MetricProperty CPU -TagProperty Name,ID -Tags @{Host = $Env:ComputerName}
            
            Description
            -----------
            This command will convert the specified object properties in to metrics and tags for a measure called 'Processes'.
    #>  
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline = $True, Position = 0)]
        [Object]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [String]
        $Measure,

        [Parameter(Mandatory = $true)]
        [String[]]
        $MetricProperty,

        [String[]]
        $TagProperty,

        [hashtable]
        $Tags
    )
    Process {
        ForEach ($ItemObject in $InputObject) {
            $Metrics = @{}

            ForEach ($Metric in $MetricProperty) {
                If ($Metric -in $ItemObject.PSobject.Properties.Name) {
                    $Metrics.Add($Metric, $ItemObject.$Metric)
                }
                Else {
                    Write-Error "$Metric is not a valid property for InputObject."
                }            
            }
            $TagData = @{}

            ForEach ($Tag in $TagProperty) {
                If ($Tag -in $ItemObject.PSobject.Properties.Name) {
                    $TagData.Add($Tag, $ItemObject.$Tag)
                }
                Else {
                    Write-Error "$Tag is not a valid property for InputObject."
                }            
            }

            If ($Tags.Count -ne 0) { $TagData += $Tags }

            [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = $Measure
                Tags       = $TagData
                Metrics    = $Metrics
            }
        }
    }
}