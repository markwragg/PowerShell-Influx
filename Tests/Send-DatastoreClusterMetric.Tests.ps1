if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

If (-not (Get-Module $Module)) { Import-Module "$Root\$Module" -Force }

Describe "Send-DatastoreClusterMetric PS$PSVersion" {
        
    InModuleScope Influx {

        Function Get-DatastoreCluster { }
        
        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
            Mock Get-DatastoreCluster { 
                [PSCustomObject]@{ 
                    Name = 'Test Datastore Cluster' 
                    CapacityGB = 12345.987
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

            it 'Should throw if no Datacenter data returned' {
                { Send-DatastoreClusterMetric } | Should Throw 'No DatastoreCluster data returned'
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