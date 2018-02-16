if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

If (-not (Get-Module $Module)) { Import-Module "$Root\$Module" -Force }

Describe "Send-Statsd PS$PSVersion" {
    
    InModuleScope Influx {
 
        Context 'Simulating successful write' {
       
            Mock Invoke-UDPSendMethod { $null } -Verifiable
                  
            $SendStatsd = 'my_metric:1|c' | Send-Statsd -IP 1.2.3.4 -Port 1234

            It 'Send-Statsd should return null' {
                $SendStatsd | Should -Be $null
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

            $SendStatsd = $MeasureObject | Send-Statsd -IP 1.2.3.4 -Port 1234

            It 'Send-Statsd should not return an error' {
                { $SendStatsd } | Should -Not -Throw
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
           
            $SendStatsd = 'my_metric:1|c' | Send-Statsd -IP 1.2.3.4 -Port 1234 -WhatIf

            It 'Send-Statsd should return null' {
                $SendStatsd | Should -Be $null
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