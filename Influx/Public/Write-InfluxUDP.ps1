Function Write-InfluxUDP {
    <#
        .SYNOPSIS
            Send metrics to the Influx UDP listener (UDP must be enabled in influxdb.conf).

        .DESCRIPTION
            Use to send data in to an Influx database via UDP by providing a hashtable of tags and values.

        .PARAMETER Measure
            The name of the measure to be updated or created.

        .PARAMETER Tags
            A hashtable of tag names and values.

        .PARAMETER Metrics
            A hashtable of metric names and values.

        .PARAMETER IP
            IP address for InfluxDB UDP listener.
    
        .PARAMETER Port
            Port for InfluxDB UDP listener.

        .EXAMPLE
            Write-InfluxUDP -Measure WebServer -Tags @{Server='Host01'} -Metrics @{CPU=100; Memory=50} -IP 1.2.3.4 -Port 8089
            
            Description
            -----------
            This command will submit the provided tag and metric data for a measure called 'WebServer' via the endpoint 'udp://1.2.3.4:8089'
    #>  
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Measure,

        [hashtable]
        $Tags,
        
        [Parameter(Mandatory=$true)]
        [hashtable]
        $Metrics,

        [datetime]
        $TimeStamp,
        
        [ipaddress]
        $IP = '127.0.0.1',
  
        [int]
        $Port = 8089
    )

    Begin {
        $Endpoint  = New-Object System.Net.IPEndPoint($IP, $Port)
        $UDPClient = New-Object System.Net.Sockets.UdpClient
    }
    Process {
        if ($TimeStamp) {
            $timeStampNanoSecs = [long]((New-TimeSpan -Start (Get-Date -Date '1970-01-01') -End (($Timestamp).ToUniversalTime())).TotalSeconds * 1E9)
        } else {
            $null = $timeStampNanoSecs
        }

        if ($Tags) {
            $TagData = foreach($Tag in $Tags.Keys) {
                "$($Tag | Out-InfluxEscapeString)=$($Tags[$Tag] | Out-InfluxEscapeString)"
            }
            $TagData = $TagData -Join ','
            $TagData = ",$TagData"
        }
    
        $Body = foreach($Metric in $Metrics.Keys) {
        
            if ($Metrics[$Metric]) {
                $MetricValue = if ($Metrics[$Metric] -isnot [ValueType]) { 
                    '"' + $Metrics[$Metric] + '"'
                } else {
                    $Metrics[$Metric] | Out-InfluxEscapeString
                }
        
                "$($Measure | Out-InfluxEscapeString)$TagData $($Metric | Out-InfluxEscapeString)=$MetricValue $timeStampNanoSecs"
            }
        }

        if ($Body) {
            $Body = $Body -Join "`n"
            $EncodedData = [System.Text.Encoding]::ASCII.GetBytes($Body)
            
            if ($PSCmdlet.ShouldProcess("$($IP):$Port","$Body")) {
                $BytesSent = $UDPClient.Send($EncodedData, $EncodedData.length, $Endpoint)
                Write-Verbose "Transmitted $BytesSent Bytes."
            }
        }
    }
    End {
        $UDPClient.Close()
    }
}
