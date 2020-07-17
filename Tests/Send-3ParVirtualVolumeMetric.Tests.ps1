if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-3ParVirtualVolumeMetric PS$PSVersion" {
 
    InModuleScope Influx {

        Function Set-3parPoshSshConnectionUsingPasswordFile { }
        Function Get-3parSystem { }
        Function Get-3parStatVV { }
               
        Mock Set-3parPoshSshConnectionUsingPasswordFile { } -Verbose
    
        Mock Write-Influx { }

        Context 'Simulating successful send' {
        
            Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable
            
            Mock Get-3parSystem { Import-Clixml -Path .\Tests\Mock-Get3parSystem.xml } -Verifiable
            
            Mock Get-3parStatVV { Import-Clixml -Path .\Tests\Mock-Get-3parStatVV.xml } -Verifiable
       
            $Send3ParSys = Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            
            it 'Should return null' {
                $Send3ParSys | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call Set-3parPoshSshConnectionUsingPasswordFile exactly 1 time' {
                Assert-MockCalled Set-3parPoshSshConnectionUsingPasswordFile -Exactly 1
            }
            It 'Should call Get-3parSystem exactly 1 time' {
                Assert-MockCalled Get-3parSystem -Exactly 1
            }
            It 'Should call Get-3parStatVV exactly 1 time' {
                Assert-MockCalled Get-3parStatVV -Exactly 1
            }
            It 'Should call Write-Influx exactly 3 times' {
                Assert-MockCalled Write-Influx -Exactly 3
            }
        }

        Context 'Simulating no system data returned' {
            
            Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable
       
            Mock Get-3parSystem { } -Verifiable
            
            Mock Get-3parStatVV { }
            
            It 'Should return null' {
                Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call Set-3parPoshSshConnectionUsingPasswordFile exactly 1 time' {
                Assert-MockCalled Set-3parPoshSshConnectionUsingPasswordFile -Exactly 1
            }
            It 'Should call Get-3parSystem exactly 1 time' {
                Assert-MockCalled Get-3parSystem -Exactly 1
            }
            It 'Should call Get-3parStatVV exactly 0 times' {
                Assert-MockCalled Get-3parStatVV -Exactly 0
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }

        Context 'Simulating no volume data returned' {
            
            Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable
       
            Mock Get-3parSystem { Import-Clixml -Path .\Tests\Mock-Get3parSystem.xml } -Verifiable
            
            Mock Get-3parStatVV { } -Verifiable
            
            It 'Should return null' {
                Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call Set-3parPoshSshConnectionUsingPasswordFile exactly 1 time' {
                Assert-MockCalled Set-3parPoshSshConnectionUsingPasswordFile -Exactly 1
            }
            It 'Should call Get-3parSystem exactly 1 time' {
                Assert-MockCalled Get-3parSystem -Exactly 1
            }
            It 'Should call Get-3parStatVV exactly 1 times' {
                Assert-MockCalled Get-3parStatVV -Exactly 1
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }

        Context 'Simulating module not found' {
        
            Mock Import-Module { Throw "The specified module 'HPE3PARPSToolkit' was not loaded because no valid module file was found in any module directory." }
        
            it 'Should throw when the module is not present' {
                { Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd } | Should Throw "The specified module 'HPE3PARPSToolkit' was not loaded because no valid module file was found in any module directory."
            }
        }        
    }
}