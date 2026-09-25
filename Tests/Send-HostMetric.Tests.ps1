if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-HostMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Get-VMHost { }
            Function Get-Stat { }

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
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
            }

            it 'Should return null' {
                $SendVMHost | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-VMHost exactly 1 time' {
                Should -Invoke Get-VMHost -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-Stat exactly 0 times' {
                Should -Invoke Get-Stat -Exactly -Times 0 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating successful send with -Stats switch' {

            BeforeAll {
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
            }

            it 'Should return null' {
                $SendVMHost | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-VMHost exactly 1 time' {
                Should -Invoke Get-VMHost -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-Stat exactly 1 time' {
                Should -Invoke Get-Stat -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating no VMHost data returned' {

            BeforeAll {
                Mock Get-VMHost { } -Verifiable

                Mock Get-Stat { }

                $SendVMHost = Send-HostMetric
            }

            it 'Should return null' {
                $SendVMHost | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-VMHost exactly 1 time' {
                Should -Invoke Get-VMHost -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-Stat exactly 0 times' {
                Should -Invoke Get-Stat -Exactly -Times 0 -Scope Context
            }
            It 'Should call Write-Influx exactly 0 times' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
        }
    }
}
