Function Get-3ParSystemMetric {
    <#
        .SYNOPSIS
            Returns 3Par System metrics as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            This function requires the HPE3PARPSToolkit module from HP.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER Tags
            An array of 3PAR system tags to be included, from those returned by Get-3ParSystem.

        .PARAMETER SANIPAddress
            The IP address of the 3PAR SAN to be queried.

        .PARAMETER SANUserName
            The username for connecting to the 3PAR.

        .PARAMETER SANPwdFile
            The encrypted password file for connecting to the 3PAR. This should be created with Set-3parPoshSshConnectionPasswordFile.

        .EXAMPLE
            Get-3ParSystemMetric -Measure 'Test3PAR' -Tags System_Name,System_Model,System_ID -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            
            Description
            -----------
            This command will return a metric object with the specified tags and 3PAR metrics for a measure called 'Test3PAR'.
    #>  
    [cmdletbinding()]
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
        $SANPwdFile
    )

    try {
        Import-Module HPE3PARPSToolkit -ErrorAction Stop

        Set-3parPoshSshConnectionUsingPasswordFile -SANIPAddress $SANIPAddress -SANUserName $SANUserName -epwdFile $SANPwdFile -ErrorAction Stop | Out-Null
    }
    catch {
        throw $_
    }
    
    $3Par = Get-3parSystem
    
    if ($3Par) {
    
        $TagData = @{}
        $3Par.GetEnumerator() | Where-Object {$_.Name -in $Tags} | ForEach-Object {
            if ($_.Value) {
                $TagData.Add($_.Name, $_.Value)
            }
        }
        
        $3ParSpace = Get-3parSpace
        
        [pscustomobject]@{
            PSTypeName = 'Metric'
            Measure    = $Measure
            Tags       = $TagData
            Metrics    = @{ 
                System_RawFreeMB    = [float]$3ParSpace."RawFree(MB)"
                System_UsableFreeMB = [float]$3ParSpace."UsableFree(MB)"
            }
        }
    }
    else {
        Write-Verbose 'No 3par system data returned'
    }
}