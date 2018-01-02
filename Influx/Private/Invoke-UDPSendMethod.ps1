Function Invoke-UDPSendMethod {
    <#
        .SYNOPSIS
            Send data to a UDP listener.

        .DESCRIPTION
            Uses the System.Net.IPEndPoint and System.Net.Sockets.UdpClient .NET methods to transmit data via UDP.

        .PARAMETER Data
            String data to be transmitted via UDP.

        .PARAMETER IP
            IP address for UDP listener. 127.0.0.1 by default.
    
        .PARAMETER Port
            Port for UDP listener. 8089 by default.

        .EXAMPLE
            'Some Data' | Invoke-UDPSendMethod -IP 1.2.3.4 -Port 1234
            
            Description
            -----------
            This command will transmit the data provided via the pipeline to the specified IP address and port via UDP.
    #>
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [parameter(Mandatory,ValueFromPipeline)]
        [string[]]
        $Data,
    
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
        ForEach ($DataItem in $Data) {
            $EncodedData = [System.Text.Encoding]::ASCII.GetBytes($DataItem)
    
            if ($PSCmdlet.ShouldProcess("$($IP):$Port","$DataItem")) {
                $BytesSent = $UDPClient.Send($EncodedData, $EncodedData.length, $Endpoint)
                Write-Verbose "Transmitted $BytesSent Bytes."
            }
        }        
    }    
    End {
        $UDPClient.Close()
    }
}