if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

If (-not (Get-Module $Module)) { Import-Module "$Root\$Module" -Force }

Describe "Write-InfluxUDP PS$PSVersion" {
    
    InModuleScope Influx {

        Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable
        Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
        Mock Invoke-UDPSendMethod { $null } -Verifiable
        Mock Invoke-UDPSendMethod { $null } -ParameterFilter {$WhatIf -eq $true}
       
        Context 'Simulating successful write' {
           
            $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server='Host01'} -Metrics @{CPU=100; Status='PoweredOn'} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 1
            }
            It 'Should call Out-InfluxEscapeString exactly 7 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 7
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 1
            }
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {
            
            $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server='Host01'} -Metrics @{CPU=100; Status='PoweredOn'} -IP 1.2.3.4 -Port 1234 -WhatIf

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Out-InfluxEscapeString exactly 7 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 7
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 0 times' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 0
            }
            It 'Should call Invoke-UDPSendMethod exactly 0 times' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 0
            }
        }
    }
}