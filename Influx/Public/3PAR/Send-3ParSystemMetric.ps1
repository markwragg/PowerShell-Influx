Function Send-3ParSystemMetric {
    <#
        .SYNOPSIS
            Sends 3Par System metrics to Influx.

        .DESCRIPTION
            This function requires the HPE3PARPSToolkit module from HP.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            An array of 3PAR system tags to be included, from those returned by Get-3ParSystem.

        .PARAMETER SANIPAddress
            The IP address of the 3PAR SAN to be queried.

        .PARAMETER SANUserName
            The username for connecting to the 3PAR.

        .PARAMETER SANPwdFile
            The encrypted password file for connecting to the 3PAR. This should be created with Set-3parPoshSshConnectionPasswordFile.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'storage'. This must exist in Influx!

        .EXAMPLE
            Send-3ParSystemMetric -Measure 'Test3PAR' -Tags System_Name,System_Model,System_ID -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            
            Description
            -----------
            This command will submit the specified tags and 3PAR metrics to a measure called 'Test3PAR'.
    #>  
    [cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [String]
        $Measure = '3PARSystem',

        [String[]]
        $Tags = ('System_Name', 'System_Model'),

        [Parameter(Mandatory = $true)]
        [String]
        $SANIPAddress,

        [Parameter(Mandatory = $true)]
        [String]
        $SANUserName, 

        [Parameter(Mandatory = $true)]
        [String]
        $SANPwdFile,

        [string]
        $Database = 'storage',
        
        [string]
        $Server = 'http://localhost:8086'

    )

    $MetricParams = @{
        Measure      = $Measure
        Tags         = $Tags
        SANIPAddress = $SANIPAddress
        SANUserName  = $SANUserName
        SANPwdFile   = $SANPwdFile
    }

    $Metric = Get-3ParSystemMetric @MetricParams
    
    if ($Metric.Measure) {

        if ($PSCmdlet.ShouldProcess($Metric.Measure)) {
            $Metric | Write-Influx -Database $Database -Server $Server
        }
    }
}