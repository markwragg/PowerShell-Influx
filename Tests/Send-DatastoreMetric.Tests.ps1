if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-DatastoreMetric PS$PSVersion" {
        
    InModuleScope Influx {

        Function Get-Datastore { }
        
        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
            Mock Get-Datastore { 
                [PSCustomObject]@{ 
                    Name        = 'Test Datastore' 
                    CapacityGB  = 12345.987
                    FreespaceGB = 654.123
                }
            } -Verifiable

            $SendDatastore = Send-DatastoreMetric
            
            it 'Should return null' {
                $SendDatastore | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-Datastore exactly 1 time' {
                Assert-MockCalled Get-Datastore -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }

        Context 'Simulating no Datastore data returned' {
        
            Mock Get-Datastore { } -Verifiable
 
            it 'Should return null' {
                Send-DatastoreMetric | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-Datastore exactly 1 time' {
                Assert-MockCalled Get-Datastore -Exactly 1
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }     
    }
}