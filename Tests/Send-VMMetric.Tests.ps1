if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-VMMetric PS$PSVersion" {
        
    InModuleScope Influx {

        Function Get-VM { }
        Function Get-Stat { }
        
        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
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
            
            it 'Should return null' {
                $SendVM | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-VM exactly 1 time' {
                Assert-MockCalled Get-VM -Exactly 1
            }
            It 'Should call Get-Stat exactly 0 times' {
                Assert-MockCalled Get-Stat -Exactly 0
            }
            It 'Should call Write-Influx exactly 2 time' {
                Assert-MockCalled Write-Influx -Exactly 2
            }  
        }

        Context 'Simulating successful send with -Stats switch' {
            
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
            
            It 'Should return null' {
                $SendVM | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-VM exactly 1 time' {
                Assert-MockCalled Get-VM -Exactly 1
            }
            It 'Should call Get-Stat exactly 2 times' {
                Assert-MockCalled Get-Stat -Exactly 1
            }
            It 'Should call Write-Influx exactly 2 times' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }
   
        Context 'Simulating no VM data returned' {
        
            Mock Get-VM { } -Verifiable
            
            Mock Get-Stat { }

            $SendVM = Send-VMMetric
            
            It 'Should return null' {
                $SendVM | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Get-VM exactly 1 time' {
                Assert-MockCalled Get-VM -Exactly 1
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