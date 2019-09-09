if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Write-Influx PS$PSVersion" {
    
    InModuleScope Influx {

        Mock Out-InfluxEscapeString { 'Some\ \,string\=' } -Verifiable
        Mock ConvertTo-UnixTimeNanosecond { '1483274062120000000' }
        Mock Invoke-RestMethod { $null } -Verifiable
        Mock Invoke-RestMethod { $null } -ParameterFilter {$WhatIf -eq $true}
       
        Context 'Simulating successful write' {
           
            $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -Database Web -Server http://localhost:8086 -Timestamp (Get-Date)

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
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
            It 'Should call Invoke-RestMethod exactly 1 time' {
                Assert-MockCalled Invoke-RestMethod -Exactly 1
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

            $WriteInflux = $MeasureObject | Write-Influx -Database Web -Server http://localhost:8086

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
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
            It 'Should call Invoke-RestMethod exactly 1 time' {
                Assert-MockCalled Invoke-RestMethod -Exactly 1
            }
        }

        Context 'Simulating -WhatIf and no Timestamp specified' {
            
            $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 100; Status = 'PoweredOn'} -Database Web -Server http://localhost:8086 -WhatIf

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
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
            It 'Should call Invoke-RestMethod exactly 0 times' {
                Assert-MockCalled Invoke-RestMethod -Exactly 0
            }
        }

        Context 'Simulating write of metric with zero value' {
           
            $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = 0} -Database Web -Server http://localhost:8086 -Timestamp (Get-Date)

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
            It 'Should call Invoke-RestMethod exactly 1 time' {
                Assert-MockCalled Invoke-RestMethod -Exactly 1
            }
        }

        Context 'Simulating write of metric with null value' {
           
            $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server = 'Host01'} -Metrics @{CPU = 50; Memory = $null} -Database Web -Server http://localhost:8086 -Timestamp (Get-Date)

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
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
            It 'Should call Invoke-RestMethod exactly 1 time' {
                Assert-MockCalled Invoke-RestMethod -Exactly 1
            }
        }

        Context 'Simulating successful write via piped object with -Bulk switch' {
            
            $MeasureObject = @(
                [pscustomobject]@{
                    PSTypeName = 'Metric'
                    Measure    = 'SomeMeasure'
                    Metrics    = @{One = 'One'; Two = 2}
                    Tags       = @{TagOne = 'One'; TagTwo = 2}
                    TimeStamp  = (Get-Date)
                },
                [pscustomobject]@{
                    PSTypeName = 'Metric'
                    Measure    = 'OtherMeasure'
                    Metrics    = @{Three = 'Four'; Five = 6}
                    Tags       = @{TagOne = 'One'; TagTwo = 2}
                    TimeStamp  = (Get-Date)
                }
            )

            $WriteInflux = $MeasureObject | Write-Influx -Bulk -Database Web -Server http://localhost:8086

            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call ConvertTo-UnixTimeNanosecond exactly 2 times' {
                Assert-MockCalled ConvertTo-UnixTimeNanosecond -Exactly 2
            }
            It 'Should call Out-InfluxEscapeString exactly 18 times' {
                Assert-MockCalled Out-InfluxEscapeString -Exactly 18
            }
            It 'Should call Invoke-RestMethod exactly 1 time' {
                Assert-MockCalled Invoke-RestMethod -Exactly 1
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

            $WriteInflux = $MeasureObject | ConvertTo-Metric -Measure Test -MetricProperty Name,SomeVal,OtherVal | Write-Influx -Database Web -ExcludeEmptyMetric -Verbose
            
            It 'Write-Influx should return null' {
                $WriteInflux | Should -Be $null
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
                Assert-MockCalled Invoke-RestMethod -Exactly 2
            }
        }
    }
}