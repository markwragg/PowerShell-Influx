if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "ConvertTo-InfluxLineString PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable

            Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
        }

        Context 'Simulating successful output' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -Timestamp (Get-Date)
            }

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
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
        }

        Context 'Simulating successful output via piped object' {

            BeforeAll {
                $MeasureObject = [pscustomobject]@{
                    PSTypeName = 'Metric'
                    Measure    = 'SomeMeasure'
                    Metrics    = @{One = 'One'; Two = 2}
                    Tags       = @{TagOne = 'One'; TagTwo = 2}
                    TimeStamp  = (Get-Date)
                }

                $WriteInflux = $MeasureObject | ConvertTo-InfluxLineString
            }

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
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
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -WhatIf
            }

            It 'ConvertTo-InfluxLineString should return null' {
                $WriteInflux | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Out-InfluxEscapeString exactly 6 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 6 -Scope Context
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 0 times' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating output of metric with zero value' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = 0} -Timestamp (Get-Date)
            }

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
            }
            It 'Should call Out-InfluxEscapeString exactly 5 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 5 -Scope Context
            }
        }

        Context 'Simulating output of metric with null value' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = $null} -Timestamp (Get-Date)
            }

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
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
        }

        Context 'Simulating skip outputting null or empty metrics when -ExcludeEmptyMetric is used' {

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

                $WriteInflux = $MeasureObject | ConvertTo-Metric -Measure Test -MetricProperty Name,SomeVal,OtherVal | ConvertTo-InfluxLineString -ExcludeEmptyMetric -Verbose
            }

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
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
            It 'Should call Out-InfluxEscapeString exactly 8 times' {
                Should -Invoke Out-InfluxEscapeString -Exactly -Times 8 -Scope Context
            }
        }
    }
}

Describe "ConvertTo-InfluxLineString Actual Output (no mock) PS$PSVersion" {

    InModuleScope Influx {

        Context 'The Tags should be sorted alphabetically' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -Measure Test -Tags @{Server='Host01';Database='MyDb';Alert='False'} -Metrics @{CPU = 20; Status = 'Online'}
            }

            It 'The output should match: Test,Alert=False,Database=MyDb,Server=Host01' {
                $WriteInflux | Should -Match 'Test,Alert=False,Database=MyDb,Server=Host01'
            }
        }

        Context 'Null Fields Should be excluded' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -ExcludeEmptyMetric -Measure Test -Tags @{Server='Host01';Database='MyDb';Alert='False'} -Metrics @{CPU=20;Status='Online';OtherValue=''}
            }

            It 'The output should exclude the field: OtherValue=$null' {
                #Powershell hashtables do not guarantee key sort order but any of the following is ok
                #Note that Tags are forcefully sorted, while fields are not
                $ValidOutputs = @(
                    'Test,Alert=False,Database=MyDb,Server=Host01 CPU=20,Status="Online"',
                    'Test,Alert=False,Database=MyDb,Server=Host01 Status="Online",CPU=20'
                )
                $ValidOutputs.Contains($WriteInflux) | Should -BeTrue
            }
        }

        Context 'Null Fields Should be excluded' {

            BeforeAll {
                $WriteInflux = ConvertTo-InfluxLineString -ExcludeEmptyMetric -Measure Test -Tags @{Server='Host01';Database='MyDb';Alert='False'} -Metrics @{CPU=20;Status='Online';OtherValue=$null}
            }

            It 'The output should exclude the field: OtherValue=""' {
                #Powershell hashtables do not guarantee key sort order but any of the following is ok
                #Note that Tags are forcefully sorted, while fields are not
                $ValidOutputs = @(
                    'Test,Alert=False,Database=MyDb,Server=Host01 CPU=20,Status="Online"',
                    'Test,Alert=False,Database=MyDb,Server=Host01 Status="Online",CPU=20'
                )
                $ValidOutputs.Contains($WriteInflux) | Should -BeTrue
            }
        }
    }
}
