Function Send-TFSBuildMetrics {
    <#
        .SYNOPSIS
            Sends TFS Build metrics to Influx.

        .DESCRIPTION
            This function requires the TFS module (install via Install-Module TFS).

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of Build definition properties to be included, from those returned by Get-TfsBuildDefinitions.
        
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
            Send-TFSBuildMetrics -Measure 'TestTFS' -Tags Name,Author -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject
            
            Description
            -----------
            This command will submit the specified tags and Build metrics to a measure called 'TestTFS'.
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = 'TFSBuild',

        [String[]]
        $Tags = ('Name','Id','Author'),

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
        $Global:TFS = @{
            root_url = $TFSRootURL
            collection = $TFSCollection
            project  = $TFSProject
        }
    
        Import-Module TFS -ErrorAction Stop
    } Catch {
        Write-Error $_
        Break
    }
    
    $Definitions = (Get-TFSBuildDefinitions)
    
    if ($Definitions) {
        
        $Builds = @()

        ForEach($Definition in $Definitions) { 
            
            $Build = (Get-TFSBuilds -Definitions $Definition.Name -Top 1 -MaxBuildsPerDefinition 1 -ErrorAction SilentlyContinue) | Select -First 1
            
            if ($Build) {
                
                $Builds += $Build
    
                $TagData = @{
                    Collection = $TFSCollection
                    Project  = $TFSProject
                    Result = $Build.Result
                }

                ($Definition | Select $Tags).PsObject.Properties | ForEach-Object {
                    if ($_.Value) {
                        $TagData.Add($_.Name,$_.Value)
                    }
                }

                $Metrics = @{
                    Name = $Build.Definition
                    Result = '"' + $Build.Result + '"'
                    Duration = $Build.Duration
                    sourceBranch = '"' + $Build.raw.sourceBranch + '"'
                    sourceVersion = '"' + $Build.raw.sourceVersion + '"'
                    
                }

                'StartTime','FinishTime' | ForEach-Object {
                    If ($Build.$_ -is [datetime]) {
                        $Metrics.Add($_,(New-TimeSpan -Start (Get-Date -Date '01/01/1970') -End $Build.$_).TotalMilliseconds) 
                    }
                }

                Write-Verbose "Sending data for $($Definition.Name) to Influx.."

                if ($PSCmdlet.ShouldProcess($Definition.Name)) {
                    Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -TimeStamp $Build.StartTime -Database $Database -Server $Server
                }     

            }else{
                Write-Warning "No build returned for $($Definition.Name), skipping.."
            }
        }

        $TagData = @{
            Collection = $TFSCollection
            Project  = $TFSProject
        }

        $Metrics = @{
            TotalBuilds = $Builds.Count
        }

        $Builds | Group-Object Result | ForEach-Object {
            $Metrics.Add("Total$($_.Name)",$_.Count)
        }
        
        if ($PSCmdlet.ShouldProcess($Definition.Name)) {
            Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
        }
        
    }else{
        Throw 'No build definition data returned'
    }
}