Function Get-IsilonStoragePoolMetric {
    <#
        .SYNOPSIS
            Returns Isilon Storage Pool usage metrics returned by the Get-isiStoragepools cmdlet as a metric object which can then be transmitted to Influx.

        .DESCRIPTION
            This function requires the IsilonPlatform module from the PSGallery.

        .PARAMETER Measure
            The name of the measure to be (ultimately) updated or created when this metric object is transmitted to Influx.

        .PARAMETER IsilonName
            The name or IP address of the Isilon to be queried.
        
        .PARAMETER IsilonPwdFile
            The encrypted credentials file for connecting to the Isilon. This should be created with Get-Credential | Export-Clixml.
        
        .PARAMETER ClusterName
            A descriptive name for the Isilon Cluster. This can be anything and is used for the Cluster tag field.

        .EXAMPLE
            Get-IsilonStoragePoolMetric -Measure 'TestIsilonSP' -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
            
            Description
            -----------
            This command will return a PowerShell object with the specified Isilon's Storage Pool metrics for a measure called 'TestIsilonSP'.
    #>  
    [cmdletbinding()]
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
        $ClusterName

    )

    Try {
        Import-Module IsilonPlatform -ErrorAction Stop

        New-isiSession -ComputerName $IsilonName -Credential ($IsilonPwdFile | Import-Clixml) -Cluster $ClusterName
    }
    Catch {
        Throw $_
    }
    
    $StoragePools = Get-isiStoragepools
    
    if ($StoragePools) {
    
        ForEach ($StoragePool in $StoragePools) {

            $TagData = @{
                Name        = $IsilonName
                Cluster     = $ClusterName
                StoragePool = $StoragePool.name
                Id          = $StoragePool.id
            }
        
            $Metrics = @{}

            $StoragePool.usage.PSObject.Properties | Where-Object {$_.Name -notin 'balanced'} | ForEach-Object {
                if ($_.Value) {
                    $Metrics.Add($_.Name, [long]$_.Value)
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
        Write-Verbose 'No Storage Pool data returned'
    }

    Remove-isiSession -Cluster $ClusterName
}