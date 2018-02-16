if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

If (-not (Get-Module $Module)) { Import-Module "$Root\$Module" -Force }

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
    }
}