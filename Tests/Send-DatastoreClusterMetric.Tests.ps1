if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-DatastoreClusterMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Get-DatastoreCluster { }

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Get-DatastoreCluster {
                    [PSCustomObject]@{
                        Name        = 'Test Datastore Cluster'
                        CapacityGB  = 12345.987
                        FreespaceGB = 654.123
                    }
                } -Verifiable

                $SendDatastore = Send-DatastoreClusterMetric
            }

            it 'Should return null' {
                $SendDatastore | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-DatastoreCluster exactly 1 time' {
                Should -Invoke Get-DatastoreCluster -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating no DatastoreCluster data returned' {

            BeforeAll {
                Mock Get-DatastoreCluster { } -Verifiable

                $SendDatastore = Send-DatastoreClusterMetric
            }

            It 'Should return null' {
                $SendDatastore | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Get-DatastoreCluster exactly 1 time' {
                Should -Invoke Get-DatastoreCluster -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 0 times' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
        }
    }
}
