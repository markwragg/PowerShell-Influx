if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-ResourcePoolMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Get-ResourcePool { }
            Function Get-VM { }

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Get-ResourcePool {
                    [PSCustomObject]@{
                        Name   = 'Test ResourcePool'
                        Parent = 'Parent Folder'
                    }
                } -Verifiable

                Mock Get-VM {
                    [PSCustomObject]@{
                        Name         = 'TestVM001'
                        ParentFolder = 'Some Folder'
                        MemoryGB     = 4
                        NumCPU       = 2
                        PowerState   = 'PoweredOn'
                    }
                    [PSCustomObject]@{
                        Name         = 'TestVM002'
                        ParentFolder = 'Some Other Folder'
                        MemoryGB     = 8
                        NumCPU       = 4
                        PowerState   = 'PoweredOff'
                    }
                } -Verifiable

                $SendResourcePool = Send-ResourcePoolMetric
            }

            it 'Should return null' {
                $SendResourcePool | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-ResourcePool exactly 1 time' {
                Should -Invoke Get-ResourcePool -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-VM exactly 1 time' {
                Should -Invoke Get-VM -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating no ResourcePool data returned' {

            BeforeAll {
                Mock Get-ResourcePool { } -Verifiable

                Mock Get-VM { }

                $SendResourcePool = Send-ResourcePoolMetric
            }

            it 'Should return null' {
                $SendResourcePool | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-ResourcePool exactly 1 time' {
                Should -Invoke Get-ResourcePool -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-VM exactly 0 times' {
                Should -Invoke Get-VM -Exactly -Times 0 -Scope Context
            }
            It 'Should call Write-Influx exactly 0 times' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
        }
    }
}
