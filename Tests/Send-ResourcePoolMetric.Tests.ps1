if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-ResourcePoolMetric PS$PSVersion" {
        
    InModuleScope Influx {

        Function Get-ResourcePool { }
        Function Get-VM { }
        
        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
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
            
            it 'Should return null' {
                $SendResourcePool | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-ResourcePool exactly 1 time' {
                Assert-MockCalled Get-ResourcePool -Exactly 1
            }
            It 'Should call Get-VM exactly 1 time' {
                Assert-MockCalled Get-VM -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }
   
        Context 'Simulating no ResourcePool data returned' {
        
            Mock Get-ResourcePool { } -Verifiable
            
            Mock Get-VM { }

            $SendResourcePool = Send-ResourcePoolMetric
            
            it 'Should return null' {
                $SendResourcePool | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-ResourcePool exactly 1 time' {
                Assert-MockCalled Get-ResourcePool -Exactly 1
            }
            It 'Should call Get-VM exactly 0 times' {
                Assert-MockCalled Get-VM -Exactly 0
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }     
    }
}