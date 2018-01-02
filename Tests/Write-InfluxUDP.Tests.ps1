if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

If (-not (Get-Module $Module)) { Import-Module "$Root\$Module" -Force }

Describe "Write-Influx PS$PSVersion" {
    
    InModuleScope Influx {

        Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable
        Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
        Mock Invoke-UDPSendMethod { $null } -Verifiable
        Mock Invoke-UDPSendMethod { $null } -ParameterFilter {$WhatIf -eq $true}
       
        Context 'Simulating successful write' {
           
            $WriteInflux = Write-InfluxUDP -Measure WebServer -Tags @{Server='Host01'} -Metrics @{CPU=100; Memory=50} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 1
            }
            It 'Should call Out-InfluxEscapeString exactly 8 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 8
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 1
            }
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {
            
            $WriteInflux = Write-InfluxUDP -Measure WebServer -Tags @{Server='Host01'} -Metrics @{CPU=100; Memory=50} -IP 1.2.3.4 -Port 1234 -WhatIf

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Out-InfluxEscapeString exactly 8 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 8
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