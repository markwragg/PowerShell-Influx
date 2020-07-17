if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "ConvertTo-InfluxLineString PS$PSVersion" {
    
    InModuleScope Influx {

        Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable

        Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
       
        Context 'Simulating successful output' {

            $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -Timestamp (Get-Date)

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 1
            }
            It 'Should call Out-InfluxEscapeString exactly 6 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 6
            }
        }

        Context 'Simulating successful output via piped object' {
            
            $MeasureObject = [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = 'SomeMeasure'
                Metrics    = @{One = 'One'; Two = 2}
                Tags       = @{TagOne = 'One'; TagTwo = 2}
                TimeStamp  = (Get-Date)
            }

            $WriteInflux = $MeasureObject | ConvertTo-InfluxLineString

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
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
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {
            
            $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -WhatIf

            It 'ConvertTo-InfluxLineString should return null' {
                $WriteInflux | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Out-InfluxEscapeString exactly 6 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 6
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 0 times' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 0
            }
        }

        Context 'Simulating output of metric with zero value' {
           
            $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = 0} -Timestamp (Get-Date)

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 1
            }
            It 'Should call Out-InfluxEscapeString exactly 5 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 5
            }
        }

        Context 'Simulating output of metric with null value' {
           
            $WriteInflux = ConvertTo-InfluxLineString -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = $null} -Timestamp (Get-Date)

            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 1 time' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 1
            }
            It 'Should call Out-InfluxEscapeString exactly 6 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 6
            }
        }

        Context 'Simulating skip outputting null or empty metrics when -ExcludeEmptyMetric is used' {

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
            
            It 'ConvertTo-InfluxLineString should return a string' {
                $WriteInflux | Should -BeOfType [string]
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
            It 'Should call Out-InfluxEscapeString exactly 8 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 8
            }
        }
    }
}

Describe "ConvertTo-InfluxLineString Actual Output (no mock) PS$PSVersion" {
    
    InModuleScope Influx {
        
        $WriteInflux = ConvertTo-InfluxLineString -Measure Test -Tags @{Server='Host01';Database='MyDb';Alert='False'} -Metrics @{CPU = 20; Status = 'Online'}
        Write-Host $WriteInflux
        Context 'The Tags should be sorted alphabetically' {
            It 'The output should be exactly: Test,Alert=False,Database=MyDb,Server=Host01 CPU=20,Status="Online"' {
                $WriteInflux | Should -BeExactly 'Test,Alert=False,Database=MyDb,Server=Host01 CPU=20,Status="Online"'
            }
        }

        $WriteInflux = ConvertTo-InfluxLineString -ExcludeEmptyMetric -Measure Test -Tags @{Server='Host01';Database='MyDb';Alert='False'} -Metrics @{CPU=20;Status='Online';OtherValue=''}
        Write-Host $WriteInflux
        Context 'Null Fields Should be excluded' {
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

        $WriteInflux = ConvertTo-InfluxLineString -ExcludeEmptyMetric -Measure Test -Tags @{Server='Host01';Database='MyDb';Alert='False'} -Metrics @{CPU=20;Status='Online';OtherValue=$null}
        Write-Host $WriteInflux
        Context 'Null Fields Should be excluded' {
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
