if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Write-Influx PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable
            Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
            Mock Invoke-RestMethod { $null } -Verifiable
            Mock Invoke-RestMethod { $null } -ParameterFilter { $WhatIf -eq $true }
        }

        Context 'Influx v1 Tests' {
            Context 'Simulating successful write' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 100; Status = 'PoweredOn' } -Database Web -Server http://localhost:8086 -Timestamp (Get-Date)
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating successful write via piped object' {

                BeforeAll {
                    $MeasureObject = [pscustomobject]@{
                        PSTypeName = 'Metric'
                        Measure    = 'SomeMeasure'
                        Metrics    = @{One = 'One'; Two = 2 }
                        Tags       = @{TagOne = 'One'; TagTwo = 2 }
                        TimeStamp  = (Get-Date)
                    }

                    $WriteInflux = $MeasureObject | Write-Influx -Database Web -Server http://localhost:8086
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating -WhatIf and no Timestamp specified' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 100; Status = 'PoweredOn' } -Database Web -Server http://localhost:8086 -WhatIf
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 0 times' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 0 -Scope Context
                }
            }

            Context 'Simulating write of metric with zero value' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 50; Memory = 0 } -Database Web -Server http://localhost:8086 -Timestamp (Get-Date)
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
                }
                It 'Should execute all verifiable mocks' {
                    Should -InvokeVerifiable
                }
                It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                    Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
                }
                It 'Should call Out-InfluxEscapeString exactly 8 times' {
                    Should -Invoke Out-InfluxEscapeString -Exactly -Times 8 -Scope Context
                }
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating write of metric with null value' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 50; Memory = $null } -Database Web -Server http://localhost:8086 -Timestamp (Get-Date)
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating successful write via piped object with -Bulk switch' {

                BeforeAll {
                    $MeasureObject = @(
                        [pscustomobject]@{
                            PSTypeName = 'Metric'
                            Measure    = 'SomeMeasure'
                            Metrics    = @{One = 'One'; Two = 2 }
                            Tags       = @{TagOne = 'One'; TagTwo = 2 }
                            TimeStamp  = (Get-Date)
                        },
                        [pscustomobject]@{
                            PSTypeName = 'Metric'
                            Measure    = 'OtherMeasure'
                            Metrics    = @{Three = 'Four'; Five = 6 }
                            Tags       = @{TagOne = 'One'; TagTwo = 2 }
                            TimeStamp  = (Get-Date)
                        }
                    )

                    $WriteInflux = $MeasureObject | Write-Influx -Bulk -Database Web -Server http://localhost:8086
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
                }
                It 'Should execute all verifiable mocks' {
                    Should -InvokeVerifiable
                }
                It 'Should call ConvertTo-UnixTimeNanosecond exactly 2 times' {
                    Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 2 -Scope Context
                }
                It 'Should call Out-InfluxEscapeString exactly 18 times' {
                    Should -Invoke Out-InfluxEscapeString -Exactly -Times 18 -Scope Context
                }
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating skip writing null or empty metrics when -ExcludeEmptyMetric is used' {

                BeforeAll {
                    Mock Write-Verbose { }

                    $MeasureObject = @(
                        [PSCustomObject]@{
                            Name     = 'Object1'
                            SomeVal  = 1
                            OtherVal = ''
                        },
                        [PSCustomObject]@{
                            Name     = 'Object2'
                            SomeVal  = $null
                            OtherVal = 2
                        }
                    )

                    $WriteInflux = $MeasureObject | ConvertTo-Metric -Measure Test -MetricProperty Name, SomeVal, OtherVal | Write-Influx -Database Web -ExcludeEmptyMetric -Verbose
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                    Should -Invoke Invoke-RestMethod -Exactly -Times 2 -Scope Context
                }
            }
        }

        Context 'Influx v2 Tests' {
            Context 'Simulating successful write' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 100; Status = 'PoweredOn' } -Organisation test -Bucket web -Token abcde -Server http://localhost:8086 -Timestamp (Get-Date)
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating successful write via piped object' {

                BeforeAll {
                    $MeasureObject = [pscustomobject]@{
                        PSTypeName = 'Metric'
                        Measure    = 'SomeMeasure'
                        Metrics    = @{One = 'One'; Two = 2 }
                        Tags       = @{TagOne = 'One'; TagTwo = 2 }
                        TimeStamp  = (Get-Date)
                    }

                    $WriteInflux = $MeasureObject | Write-Influx -Organisation test -Bucket web -Token abcde -Server http://localhost:8086
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating -WhatIf and no Timestamp specified' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 100; Status = 'PoweredOn' } -Organisation test -Bucket web -Token abcde -Server http://localhost:8086 -WhatIf
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 0 times' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 0 -Scope Context
                }
            }

            Context 'Simulating write of metric with zero value' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 50; Memory = 0 } -Organisation test -Bucket web -Token abcde -Server http://localhost:8086 -Timestamp (Get-Date)
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
                }
                It 'Should execute all verifiable mocks' {
                    Should -InvokeVerifiable
                }
                It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                    Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
                }
                It 'Should call Out-InfluxEscapeString exactly 8 times' {
                    Should -Invoke Out-InfluxEscapeString -Exactly -Times 8 -Scope Context
                }
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating write of metric with null value' {

                BeforeAll {
                    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01' } -Metrics @{CPU = 50; Memory = $null } -Organisation test -Bucket web -Token abcde -Server http://localhost:8086 -Timestamp (Get-Date)
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating successful write via piped object with -Bulk switch' {

                BeforeAll {
                    $MeasureObject = @(
                        [pscustomobject]@{
                            PSTypeName = 'Metric'
                            Measure    = 'SomeMeasure'
                            Metrics    = @{One = 'One'; Two = 2 }
                            Tags       = @{TagOne = 'One'; TagTwo = 2 }
                            TimeStamp  = (Get-Date)
                        },
                        [pscustomobject]@{
                            PSTypeName = 'Metric'
                            Measure    = 'OtherMeasure'
                            Metrics    = @{Three = 'Four'; Five = 6 }
                            Tags       = @{TagOne = 'One'; TagTwo = 2 }
                            TimeStamp  = (Get-Date)
                        }
                    )

                    $WriteInflux = $MeasureObject | Write-Influx -Bulk -Organisation test -Bucket web -Token abcde -Server http://localhost:8086
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
                }
                It 'Should execute all verifiable mocks' {
                    Should -InvokeVerifiable
                }
                It 'Should call ConvertTo-UnixTimeNanosecond exactly 2 times' {
                    Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 2 -Scope Context
                }
                It 'Should call Out-InfluxEscapeString exactly 18 times' {
                    Should -Invoke Out-InfluxEscapeString -Exactly -Times 18 -Scope Context
                }
                It 'Should call Invoke-RestMethod exactly 1 time' {
                    Should -Invoke Invoke-RestMethod -Exactly -Times 1 -Scope Context
                }
            }

            Context 'Simulating skip writing null or empty metrics when -ExcludeEmptyMetric is used' {

                BeforeAll {
                    Mock Write-Verbose { }

                    $MeasureObject = @(
                        [PSCustomObject]@{
                            Name     = 'Object1'
                            SomeVal  = 1
                            OtherVal = ''
                        },
                        [PSCustomObject]@{
                            Name     = 'Object2'
                            SomeVal  = $null
                            OtherVal = 2
                        }
                    )

                    $WriteInflux = $MeasureObject | ConvertTo-Metric -Measure Test -MetricProperty Name, SomeVal, OtherVal | Write-Influx -Organisation test -Bucket web -Token abcde -ExcludeEmptyMetric -Verbose
                }

                It 'Write-Influx should return null' {
                    $WriteInflux | Should -Be $null
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
                    Should -Invoke Invoke-RestMethod -Exactly -Times 2 -Scope Context
                }
            }
        }
    }
}
