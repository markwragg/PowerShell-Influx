Function Get-TFSBuildMetric {
    <#
        .SYNOPSIS
            Returns TFS Build metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            This function requires the TFS module (install via Install-Module TFS).

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of Build definition properties to be included, from those returned by Get-TfsBuildDefinitions.
        
        .PARAMETER Top
            An integer defining the number of most recent builds to return. Default: 100.
        
        .PARAMETER Latest
            Switch parameter. When used returns only the most recent build for each distinct definition.

        .PARAMETER TFSRootURL
            The root URL for TFS, e.g https://yourserver.yoursite.com/TFS
        
        .PARAMETER TFSCollection
            The name of the TFS collection to query.
        
        .PARAMETER TFSProject
            The name of the TFS project to query.
    
        .EXAMPLE
            Get-TFSBuildMetric -Measure 'TestTFS' -Tags Name,Author -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject
            
            Description
            -----------
            This command will return the specified tags and build metrics of a measure called 'TestTFS' as a PowerShell object.
    #>  
    [cmdletbinding()]
    param(
        [String]
        $Measure = 'TFSBuild',

        [String[]]
        $Tags = ('Definition', 'Id', 'Result'),

        [int]
        $Top = 100,

        [switch]
        $Latest,

        [Parameter(Mandatory = $true)]
        [string]
        $TFSRootURL,
        
        [Parameter(Mandatory = $true)]
        [string]
        $TFSCollection,
        
        [Parameter(Mandatory = $true)]
        [string]
        $TFSProject
    )

    try {    
        Import-Module TFS -ErrorAction Stop
    }
    catch {
        throw $_
    }
    
    $global:tfs = @{
        root_url   = $TFSRootURL
        collection = $TFSCollection
        project    = $TFSProject
    }
    
    Write-Verbose "TFS settings:`n`n$($global:tfs)"

    Write-Verbose "`nGetting builds.."
    $Builds = Get-TFSBuilds -Top $Top | Where-Object { $_.StartTime }

    If ($Latest) {
        $Builds = $Builds | Group-Object Definition | ForEach-Object { $_.Group | Sort-Object StartTime -Descending | Select-Object -First 1 }
    }

    if ($Builds) {
    
        ForEach ($Build in $Builds) { 
         
            $TagData = @{
                Collection  = $TFSCollection
                Project     = $TFSProject
                RequestedBy = $Build.raw.requestedBy.displayname
            }

            ($Build | Select-Object $Tags).PsObject.Properties | ForEach-Object {
                if ($_.Value) {
                    $TagData.Add($_.Name, $_.Value)
                }
            }
                
            #Used to support row highlighting for non-successful builds
            $ResultNumeric = Switch ($Build.Result) {
                'partiallySucceeded' { 1 }
                'failed' { 2 }
                default { $null }
            }
                
            $Metrics = @{
                Name          = $Build.Definition
                Result        = $Build.Result
                ResultNumeric = $ResultNumeric
                Duration      = $Build.Duration
                sourceBranch  = $Build.raw.sourceBranch
                sourceVersion = $Build.raw.sourceVersion
                Id            = $Build.Id
                RequestedBy   = $Build.raw.requestedBy.displayname
            }

            'StartTime', 'FinishTime' | ForEach-Object {
                If ($Build.$_ -is [datetime]) {
                    $Metrics.Add($_, ($Build.$_ | ConvertTo-UnixTimeMillisecond)) 
                }
            }
            
            [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = $Measure
                Tags       = $TagData
                Metrics    = $Metrics
                TimeStamp  = $Build.StartTime
            }
        } 
    }
    else {
        Write-Verbose 'No build data returned'
    }
}