if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Write-InfluxUDP PS$PSVersion" {
    
    InModuleScope Influx {

        Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable
        Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
        Mock Invoke-UDPSendMethod { $null } -Verifiable
        Mock Invoke-UDPSendMethod { $null } -ParameterFilter {$WhatIf -eq $true}
       
        Context 'Simulating successful write' {
           
            $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)

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

        Context 'Simulating successful write via piped object' {
           
            $MeasureObject = [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = 'SomeMeasure'
                Metrics    = @{One = 'One'; Two = 2}
                Tags       = @{TagOne = 'One'; TagTwo = 2}
                TimeStamp  = (Get-Date)
            }

            $WriteInfluxUDP = $MeasureObject | Write-InfluxUDP -IP 1.2.3.4 -Port 1234

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 1
            }
            It 'Should call Out-InfluxEscapeString exactly 9 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 9
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 1
            }
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {
            
            $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -IP 1.2.3.4 -Port 1234 -WhatIf

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

        Context 'Simulating write of metric with zero value' {
           
            $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = 0} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
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

        Context 'Simulating write of metric with null value' {
           
            $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = $null} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)

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

        Context 'Simulating skip writing null or empty metrics when -ExcludeEmptyMetric is used' {

            Mock Write-Verbose {}
            
            $MeasureObject = @(
                [PSCustomObject]@{
                    Name = 'Object1'
                    SomeVal = 1
                    OtherVal = ''
                },
                [PSCustomObject]@{
                    Name = 'Object2'
                    SomeVal = $null
                    OtherVal = 2
                }
            )

            $WriteInfluxUDP = $MeasureObject | ConvertTo-Metric -Measure Test -MetricProperty Name,SomeVal,OtherVal | Write-InfluxUDP -IP 1.2.3.4 -Port 1234 -ExcludeEmptyMetric -Verbose
            
            It 'Write-InfluxUDP should return an array of two nulls' {
                $WriteInfluxUDP | Should -Be @($null,$null)
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Write-Verbose exactly 2 times' {
                Assert-MockCalled Write-Verbose -Exactly 2
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 0 times' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 0
            }
            It 'Should call Out-InfluxEscapeString exactly 10 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 10
            }
            It 'Should call Invoke-RestMethod exactly 2 times' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 2
            }
        }
    }
}