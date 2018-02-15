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
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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
        $TFSProject,
        
        [string]
        $Database = 'tfs',
        
        [string]
        $Server = 'http://localhost:8086'

    )

    $MetricParams = @{
        Measure       = $Measure
        Tags          = $Tags
        Top           = $Top
        Latest        = $Latest
        TFSRootURL    = $TFSRootURL
        TFSCollection = $TFSCollection
        TFSProject    = $TFSProject
    }

    $Metric = Get-TFSBuildMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}