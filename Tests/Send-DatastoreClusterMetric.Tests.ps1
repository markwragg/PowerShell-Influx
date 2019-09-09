if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-DatastoreClusterMetric PS$PSVersion" {
        
    InModuleScope Influx {

        Function Get-DatastoreCluster { }
        
        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
            Mock Get-DatastoreCluster { 
                [PSCustomObject]@{ 
                    Name        = 'Test Datastore Cluster' 
                    CapacityGB  = 12345.987
                    FreespaceGB = 654.123
                }
            } -Verifiable

            $SendDatastore = Send-DatastoreClusterMetric
            
            it 'Should return null' {
                $SendDatastore | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-DatastoreCluster exactly 1 time' {
                Assert-MockCalled Get-DatastoreCluster -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }

        Context 'Simulating no DatastoreCluster data returned' {
        
            Mock Get-DatastoreCluster { } -Verifiable
            
            It 'Should return null' {
                Send-DatastoreClusterMetric | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-DatastoreCluster exactly 1 time' {
                Assert-MockCalled Get-DatastoreCluster -Exactly 1
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }     
    }
}