Function Send-IsilonStoragePoolMetric {
    <#
        .SYNOPSIS
            Sends Isilon Storage Pool usage metrics returned by the Get-isiStoragepools cmdlet from the IsilonPlatform module to Influx.

        .DESCRIPTION
            This function requires the IsilonPlatform module from the PSGallery.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER IsilonName
            The name or IP address of the Isilon to be queried.
        
        .PARAMETER IsilonPwdFile
            The encrypted credentials file for connecting to the Isilon. This should be created with Get-Credential | Export-Clixml.
        
        .PARAMETER ClusterName
            A descriptive name for the Isilon Cluster. This can be anything and is used for the Cluster tag field.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'storage'. This must exist in Influx!

        .EXAMPLE
            Send-IsilonStoragePoolMetric -Measure 'TestIsilonSP' -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
            
            Description
            -----------
            This command will submit the specified Isilon's Storage Pool metrics to a measure called 'TestIsilonSP'.
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = 'IsilonStoragePool',

        [Parameter(Mandatory = $true)]
        [String]
        $IsilonName,

        [Parameter(Mandatory = $true)]
        [String]
        $IsilonPwdFile,

        [Parameter(Mandatory = $true)]
        [String]
        $ClusterName,

        [string]
        $Database = 'storage',
        
        [string]
        $Server = 'http://localhost:8086'

    )

    $MetricParams = @{
        Measure       = $Measure
        IsilonName    = $IsilonName
        IsilonPwdFile = $IsilonPwdFile
        ClusterName   = $ClusterName
    }

    $Metric = Get-IsilonStoragePoolMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}