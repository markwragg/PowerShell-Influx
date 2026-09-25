if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-VMMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Get-VM { }
            Function Get-Stat { }

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Get-VM {
                    [PSCustomObject]@{
                        Name         = 'TestVM001'
                        ParentFolder = 'Some Folder'
                        MemoryGB     = 4
                        NumCPU       = 2
                        PowerState   = 1
                    }
                    [PSCustomObject]@{
                        Name         = 'TestVM002'
                        ParentFolder = 'Some Other Folder'
                        MemoryGB     = 8
                        NumCPU       = 4
                        PowerState   = 0
                    }
                } -Verifiable

                Mock Get-Stat { }

                $SendVM = Send-VMMetric
            }

            it 'Should return null' {
                $SendVM | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-VM exactly 1 time' {
                Should -Invoke Get-VM -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-Stat exactly 0 times' {
                Should -Invoke Get-Stat -Exactly -Times 0 -Scope Context
            }
            It 'Should call Write-Influx exactly 2 time' {
                Should -Invoke Write-Influx -Exactly -Times 2 -Scope Context
            }
        }

        Context 'Simulating successful send with -Stats switch' {

            BeforeAll {
                Mock Get-VM {
                    [PSCustomObject]@{
                        Name          = 'TestVM001'
                        ParentFolder  = 'Some Folder'
                        MemoryGB      = 4
                        NumCPU        = 2
                        PowerState    = 1
                        ExtensionData = @{
                            Summary = @{
                                QuickStats = [PSCustomObject]@{
                                    OverallCpuUsage  = 10
                                    GuestMemoryUsage = 50
                                    HostMemoryUsage  = 150
                                    UptimeSeconds    = 1234567890
                                }
                            }
                        }
                    }
                } -Verifiable

                Mock Get-Stat {
                    [PSCustomObject]@{
                        Entity    = @{Name = 'TestVM001'}
                        MetricID  = 'cpu.usage.average'
                        Timestamp = '12/31/2017 12:00:00 AM'
                        Value     = '0.11'
                        Unit      = '%'
                    }
                } -Verifiable

                $SendVM = Send-VMMetric -Stats
            }

            It 'Should return null' {
                $SendVM | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-VM exactly 1 time' {
                Should -Invoke Get-VM -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-Stat exactly 2 times' {
                Should -Invoke Get-Stat -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 2 times' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating no VM data returned' {

            BeforeAll {
                Mock Get-VM { } -Verifiable

                Mock Get-Stat { }

                $SendVM = Send-VMMetric
            }

            It 'Should return null' {
                $SendVM | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-VM exactly 1 time' {
                Should -Invoke Get-VM -Exactly -Times 1 -Scope Context
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
