if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Write-InfluxUDP PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable
            Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
            Mock Invoke-UDPSendMethod { $null } -Verifiable
            Mock Invoke-UDPSendMethod { $null } -ParameterFilter {$WhatIf -eq $true}
        }

        Context 'Simulating successful write' {

            BeforeAll {
                $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)
            }

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
            }
            It 'Should call Out-InfluxEscapeString exactly 7 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 7 -Scope Context
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Should -Invoke Invoke-UDPSendMethod -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating successful write via piped object' {

            BeforeAll {
                $MeasureObject = [pscustomobject]@{
                    PSTypeName = 'Metric'
                    Measure    = 'SomeMeasure'
                    Metrics    = @{One = 'One'; Two = 2}
                    Tags       = @{TagOne = 'One'; TagTwo = 2}
                    TimeStamp  = (Get-Date)
                }

                $WriteInfluxUDP = $MeasureObject | Write-InfluxUDP -IP 1.2.3.4 -Port 1234
            }

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
            }
            It 'Should call Out-InfluxEscapeString exactly 9 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 9 -Scope Context
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Should -Invoke Invoke-UDPSendMethod -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {

            BeforeAll {
                $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -IP 1.2.3.4 -Port 1234 -WhatIf
            }

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Out-InfluxEscapeString exactly 7 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 7 -Scope Context
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 0 times' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 0 -Scope Context
            }
            It 'Should call Invoke-UDPSendMethod exactly 0 times' {
                Should -Invoke Invoke-UDPSendMethod -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating write of metric with zero value' {

            BeforeAll {
                $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = 0} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)
            }

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
            }
            It 'Should call Out-InfluxEscapeString exactly 6 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 6 -Scope Context
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Should -Invoke Invoke-UDPSendMethod -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating write of metric with null value' {

            BeforeAll {
                $WriteInfluxUDP = Write-InfluxUDP -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = $null} -IP 1.2.3.4 -Port 1234 -Timestamp (Get-Date)
            }

            It 'Write-InfluxUDP should return null' {
                $WriteInfluxUDP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
            }
            It 'Should call Out-InfluxEscapeString exactly 7 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 7 -Scope Context
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Should -Invoke Invoke-UDPSendMethod -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating skip writing null or empty metrics when -ExcludeEmptyMetric is used' {

            BeforeAll {
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
            }

            It 'Write-InfluxUDP should return an array of two nulls' {
                $WriteInfluxUDP | Should -Be @($null,$null)
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Write-Verbose exactly 2 times' {
                Should -Invoke Write-Verbose -Exactly -Times 2 -Scope Context
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 0 times' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 0 -Scope Context
            }
            It 'Should call Out-InfluxEscapeString exactly 10 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 10 -Scope Context
            }
            It 'Should call Invoke-RestMethod exactly 2 times' {
                Should -Invoke Invoke-UDPSendMethod -Exactly -Times 2 -Scope Context
            }
        }
    }
}
