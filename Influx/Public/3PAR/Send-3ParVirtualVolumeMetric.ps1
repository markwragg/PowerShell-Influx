Function Send-3ParVirtualVolumeMetric {
    <#
        .SYNOPSIS
            Sends the 3Par Virtual Volume metrics returned by Get-3parStatVV to Influx.

        .DESCRIPTION
            This function requires the HPE3PARPSToolkit module from HP.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER SANIPAddress
            The IP address of the 3PAR SAN to be queried.

        .PARAMETER SANUserName
            The username for connecting to the 3PAR.

        .PARAMETER SANPasswordFile
            The encrypted password file for connecting to the 3PAR. This should be created with Set-3parPoshSshConnectionPasswordFile.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'storage'. This must exist in Influx!

        .EXAMPLE
            Send-3ParVirtualVolumeMetric -Measure 'Test3PARVV' -SANIPAddress 1.2.3.4 -SANUsername admin -SANPasswordFile C:\scripts\3par.pwd
            
            Description
            -----------
            This command will submit the 3PAR Virtual Volume metrics to a measure called 'Test3PARVV'.
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = '3PARVirtualVolume',

        [Parameter(Mandatory=$true)]
        [String]
        $SANIPAddress,

        [Parameter(Mandatory=$true)]
        [String]
        $SANUserName, 

        [Parameter(Mandatory=$true)]
        [String]
        $SANPasswordFile,

        [string]
        $Database = 'storage',
        
        [string]
        $Server = 'http://localhost:8086'

    )

    Try {
        Import-Module HPE3PARPSToolkit -ErrorAction Stop

        Set-3parPoshSshConnectionUsingPasswordFile -SANIPAddress $SANIPAddress -SANUserName $SANUserName -epwdFile $SANPasswordFile -ErrorAction Stop | Out-Null
    } Catch {
        Write-Error $_
        Break
    }
    
    $3Par = Get-3parSystem
    
    if ($3Par) {
    
        $VVStats = (Get-3parStatVV -Iteration 1) | Where-Object {$_.VVname -notin 'admin','.srdata'}
        
        if ($VVStats) {

            ForEach($VV in $VVStats) {

                $TagData = @{
                    System_Name = $3Par.System_Name
                    VVname = $VV.VVname
                }
        
                $Metrics = @{}

                $VV.PSObject.Properties | Where-Object {$_.Name -notin 'VVname','Time','Date','r/w'} | ForEach-Object {
                    if ($_.Value) {
                        $Metrics.Add($_.Name,[float]$_.Value)
                    }
                }   
            
                Write-Verbose "Sending data for $($VV.VVname) to Influx.."

                if ($PSCmdlet.ShouldProcess($VV.VVname)) {
                    Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
                }
            }

        }else{
            Throw 'No Virtual Volume data returned'
        }

    }else{
        Throw 'No 3par system data returned'
    }
}