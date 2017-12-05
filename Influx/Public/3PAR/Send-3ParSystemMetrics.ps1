Function Send-3ParSystemMetrics {
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

        .PARAMETER SANPasswordFile
            The encrypted password file for connecting to the 3PAR. This should be created with Set-3parPoshSshConnectionPasswordFile.

        .PARAMETER Server
            The URL and port for the Influx REST API. Default: 'http://localhost:8086'

        .PARAMETER Database
            The name of the Influx database to write to. Default: 'storage'. This must exist in Influx!

        .EXAMPLE
            Send-3ParMetrics -Measure 'Test3PAR' -Tags System_Name,System_Model,System_ID -SANIPAddress 1.2.3.4 -SANUsername admin -SANPasswordFile C:\scripts\3par.pwd
            
            Description
            -----------
            This command will submit the specified tags and 3PAR metrics to a measure called 'Test3PAR'.
    #>  
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [String]
        $Measure = '3PARSystem',

        [String[]]
        $Tags = ('System_Name','System_Model'),

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

        Set-3parPoshSshConnectionUsingPasswordFile -SANIPAddress $SANIPAddress -SANUserName $SANUserName -epwdFile $SANPasswordFile -ErrorAction Stop
    } Catch {
        Write-Error $_
        Break
    }
    
    $3Par = Get-3parSystem
    
    if ($3Par) {
    
        $TagData = @{}
        $TagData = $3Par.GetEnumerator() | Where {$_.Name -in $Tags} | ForEach-Object {
            if ($_.Value) {
                $TagData.Add($_.Name,$_.Value)
            }
        }
        
        $3ParSpace = Get-3parSpace
                
        $Metrics = @{ 
            System_RawFreeMB = $3ParSpace."RawFree(MB)"
            System_UsableFreeMB = $3ParSpace."UsableFree(MB)"
        }
            
        Write-Verbose "Sending data for $($3Par.System_Name) to Influx.."

        if ($PSCmdlet.ShouldProcess($3Par.System_Name)) {
            Write-Influx -Measure $Measure -Tags $TagData -Metrics $Metrics -Database $Database -Server $Server
        }
        
    }else{
        Throw 'No 3par system data returned'
    }
}