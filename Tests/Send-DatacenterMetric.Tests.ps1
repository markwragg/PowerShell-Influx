if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-DatacenterMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Get-Datacenter { }
            Function Get-VM { }

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Get-Datacenter {
                    [PSCustomObject]@{
                        Name         = 'Test Datacenter'
                        ParentFolder = 'Some Folder'
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

                $SendDC = Send-DatacenterMetric
            }

            it 'Should return null' {
                $SendDC | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-Datacenter exactly 1 time' {
                Should -Invoke Get-Datacenter -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-VM exactly 1 time' {
                Should -Invoke Get-VM -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating no Datacenter data returned' {

            BeforeAll {
                Mock Get-Datacenter { } -Verifiable

                Mock Get-VM { }

                $SendDC = Send-DatacenterMetric
            }

            It 'Should return null' {
                $SendDC | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-Datacenter exactly 1 time' {
                Should -Invoke Get-Datacenter -Exactly -Times 1 -Scope Context
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
