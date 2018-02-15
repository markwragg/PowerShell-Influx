Function Get-3ParVirtualVolumeMetric {
    <#
        .SYNOPSIS
            Returns the 3Par Virtual Volume metrics (as returned by Get-3parStatVV) as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            This function requires the HPE3PARPSToolkit module from HP.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER SANIPAddress
            The IP address of the 3PAR SAN to be queried.

        .PARAMETER SANUserName
            The username for connecting to the 3PAR.

        .PARAMETER SANPwdFile
            The encrypted password file for connecting to the 3PAR. This should be created with Set-3parPoshSshConnectionPasswordFile.

        .EXAMPLE
            Get-3ParVirtualVolumeMetric -Measure 'Test3PARVV' -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            
            Description
            -----------
            This command will return a PowerShell object with the 3PAR Virtual Volume metrics for a measure called 'Test3PARVV'.
    #>  
    [cmdletbinding()]
    param(
        [String]
        $Measure = '3PARVirtualVolume',

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
    
        $VVStats = (Get-3parStatVV -Iteration 1) | Where-Object {$_.VVname -notin 'admin', '.srdata'}
        
        if ($VVStats) {

            ForEach ($VV in $VVStats) {

                $TagData = @{
                    System_Name = $3Par.System_Name
                    VVname      = $VV.VVname
                }
        
                $Metrics = @{}

                $VV.PSObject.Properties | Where-Object {$_.Name -notin 'VVname', 'Time', 'Date', 'r/w'} | ForEach-Object {
                    if ($_.Value) {
                        $Metrics.Add($_.Name, [float]$_.Value)
                    }
                }   
            
                [pscustomobject]@{
                    PSTypeName = 'Metric'
                    Measure    = $Measure
                    Tags       = $TagData
                    Metrics    = $Metrics
                }
            }
        }
        else {
            Write-Verbose 'No Virtual Volume data returned'
        }
    }
    else {
        Write-Verbose 'No 3par system data returned'
    }
}