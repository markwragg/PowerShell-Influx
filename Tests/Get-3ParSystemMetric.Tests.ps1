if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Get-3ParSystemMetric PS$PSVersion" {

    InModuleScope Influx {

        Function Set-3parPoshSshConnectionUsingPasswordFile { }
        Function Get-3parSystem { }
        Function Get-3parSpace { }
        
        Mock Set-3parPoshSshConnectionUsingPasswordFile { } -Verbose
        
        Mock Get-3parSpace { Import-Clixml .\Tests\Mock-Get3parSpace.xml } -Verifiable

        Mock Write-Influx { }

        Context 'Simulating successful get' {
        
            Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable
            
            Mock Get-3parSystem { Import-Clixml .\Tests\Mock-Get3parSystem.xml } -Verifiable
            
            $Get3ParSys = Get-3ParSystemMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            
            it 'Should return a 3PARSystem measure' {
                $Get3ParSys.measure | Should -Be '3PARSystem'
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
            It 'Should call Get-3parSpace exactly 1 time' {
                Assert-MockCalled Get-3parSpace -Exactly 1
            }
        }

        Context 'Simulating no system data returned' {
            
            Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable
       
            Mock Get-3parSystem { } -Verifiable
            
            It 'Should return null' {
                Get-3ParSystemMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd | Should -Be $null
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
            It 'Should call Get-3parSpace exactly 0 times' {
                Assert-MockCalled Get-3parSpace -Exactly 0
            }
        }

        Context 'Simulating module not found' {
        
            Mock Import-Module { Throw "The specified module 'HPE3PARPSToolkit' was not loaded because no valid module file was found in any module directory." }
        
            it 'Should throw when the module is not present' {
                { Get-3ParSystemMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd } | Should Throw "The specified module 'HPE3PARPSToolkit' was not loaded because no valid module file was found in any module directory."
            }
        }        
    }
}