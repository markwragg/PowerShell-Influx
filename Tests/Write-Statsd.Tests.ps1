if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Write-StatsD PS$PSVersion" {
    
    InModuleScope Influx {
 
        Context 'Simulating successful write' {
       
            Mock Invoke-UDPSendMethod { $null } -Verifiable
                  
            $WriteStatsD = 'my_metric:1|c' | Write-StatsD -IP 1.2.3.4 -Port 1234

            It 'Write-StatsD should return null' {
                $WriteStatsD | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 1
            }
        }

        Context 'Simulating successful write with object input' {
       
            Mock Invoke-UDPSendMethod { $null } -Verifiable
                  
            $MeasureObject = [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = 'SomeMeasure'
                Metrics    = @{One = 'One'; Two = 2}
                Tags       = @{TagOne = 'One'; TagTwo = 2}
                TimeStamp  = (Get-Date)
            }

            $WriteStatsD = $MeasureObject | Write-StatsD -IP 1.2.3.4 -Port 1234

            It 'Write-StatsD should not return an error' {
                { $WriteStatsD } | Should -Not -Throw
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Invoke-UDPSendMethod exactly 1 time' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 2
            }
        }

        Context 'Simulating -WhatIf' {
       
            Mock Invoke-UDPSendMethod { $null } -ParameterFilter {$WhatIf -eq $true}
           
            $WriteStatsD = 'my_metric:1|c' | Write-StatsD -IP 1.2.3.4 -Port 1234 -WhatIf

            It 'Write-StatsD should return null' {
                $WriteStatsD | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Invoke-UDPSendMethod exactly 0 times' {
                Assert-MockCalled Invoke-UDPSendMethod -Exactly 0
            }
        }
    }
}