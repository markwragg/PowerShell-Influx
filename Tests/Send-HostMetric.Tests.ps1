if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-HostMetric PS$PSVersion" {
        
    InModuleScope Influx {

        Function Get-VMHost { }
        Function Get-Stat { }
        
        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
            Mock Get-VMHost { 
                [PSCustomObject]@{ 
                    Name          = 'Test VMHost' 
                    CpuTotalMhz   = 30396
                    CpuUsageMhz   = 7651
                    MemoryTotalGB = 255.906
                    MemoryUsageGB = 123.456

                }
            } -Verifiable

            Mock Get-Stat { }

            $SendVMHost = Send-HostMetric
            
            it 'Should return null' {
                $SendVMHost | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-VMHost exactly 1 time' {
                Assert-MockCalled Get-VMHost -Exactly 1
            }
            It 'Should call Get-Stat exactly 0 times' {
                Assert-MockCalled Get-Stat -Exactly 0
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }

        Context 'Simulating successful send with -Stats switch' {
            
            Mock Get-VMHost { 
                [PSCustomObject]@{ 
                    Name          = 'Test VMHost' 
                    CpuTotalMhz   = 30396
                    CpuUsageMhz   = 7651
                    MemoryTotalGB = 255.906
                    MemoryUsageGB = 123.456

                }
            } -Verifiable

            Mock Get-Stat {
                [PSCustomObject]@{ 
                    Entity    = @{Name = 'Test VMHost'}
                    MetricID  = 'cpu.usage.average'
                    Timestamp = '12/31/2017 12:00:00 AM'
                    Value     = '0.11'
                    Unit      = '%'
                }
            } -Verifiable

            $SendVMHost = Send-HostMetric -Stats
            
            it 'Should return null' {
                $SendVMHost | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-VMHost exactly 1 time' {
                Assert-MockCalled Get-VMHost -Exactly 1
            }
            It 'Should call Get-Stat exactly 1 time' {
                Assert-MockCalled Get-Stat -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }

        Context 'Simulating no VMHost data returned' {
        
            Mock Get-VMHost { } -Verifiable
            
            Mock Get-Stat { }
 
            it 'Should return null' {
                Send-HostMetric | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-VMHost exactly 1 time' {
                Assert-MockCalled Get-VMHost -Exactly 1
            }
            It 'Should call Get-Stat exactly 0 times' {
                Assert-MockCalled Get-Stat -Exactly 0
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }     
    }
}