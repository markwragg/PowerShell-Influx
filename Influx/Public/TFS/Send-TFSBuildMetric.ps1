Function Send-TFSBuildMetric {
    <#
        .SYNOPSIS
            Sends TFS Build metrics to Influx.

        .DESCRIPTION
            This function requires the TFS module (install via Install-Module TFS).

        .PARAMETER Measure
            The name of the measure to be updated or created.

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
                         
        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'TFS'. This must exist in Influx!

        .EXAMPLE
            Send-TFSBuildMetric -Measure 'TestTFS' -Tags Name,Author -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject
            
            Description
            -----------
            This command will submit the specified tags and Build metrics to a measure called 'TestTFS'.
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'TFSBuild',

        [String[]]
        $Tags = ('Definition','Id','Result'),

        [int]
        $Top = 100,

        [switch]
        $Latest,

        [Parameter(Mandatory=$true)]
        [string]
        $TFSRootURL,
        
        [Parameter(Mandatory=$true)]
        [string]
        $TFSCollection,
        
        [Parameter(Mandatory=$true)]
        [string]
        $TFSProject,
        
        [string]
        $Database = 'tfs',
        
        [string]
        $Server = 'http://localhost:8086'

    )

    Try {    
        Import-Module TFS -ErrorAction Stop
    } Catch {
        Write-Error $_
        Break
    }
    
    Write-Verbose 'Getting builds..'
    $Builds = Get-TFSBuilds -Top $Top | Where-Object { $_.StartTime }

    If ($Latest) {
        $Builds = $Builds | Group-Object Definition | ForEach-Object { $_.Group | Sort-Object StartTime -Descending | Select-Object -First 1 }
    }

    if ($Builds) {
    
        ForEach($Build in $Builds) { 
         
            $TagData = @{
                Collection  = $TFSCollection
                Project     = $TFSProject
                RequestedBy = $Build.raw.requestedBy.displayname
            }

            ($Build | Select-Object $Tags).PsObject.Properties | ForEach-Object {
                if ($_.Value) {
                    $TagData.Add($_.Name,$_.Value)
                }
            }
                
            #Used to support row highlighting for non-successful builds
            $ResultNumeric = Switch ($Build.Result) {
                'partiallySucceeded' { 1 }
                'failed'             { 2 }
                default              { $null }
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

            'StartTime','FinishTime' | ForEach-Object {
                If ($Build.$_ -is [datetime]) {
                    $Metrics.Add($_,($Build.$_ | ConvertTo-UnixTimeMillisecond)) 
                }
            }

            Write-Verbose "Sending data for $($Definition.Name) to Influx.."

            if ($PSCmdlet.ShouldProcess($Definition.Name)) {
                Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -TimeStamp $Build.StartTime -Database $Database -Server $Server
            }     
        }
        
    }else{
        Throw 'No build data returned'
    }
}