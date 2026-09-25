if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-3ParVirtualVolumeMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Set-3parPoshSshConnectionUsingPasswordFile { }
            Function Get-3parSystem { }
            Function Get-3parStatVV { }

            Mock Set-3parPoshSshConnectionUsingPasswordFile { } -Verbose

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable

                Mock Get-3parSystem { Import-Clixml -Path .\Tests\Mock-Get3parSystem.xml } -Verifiable

                Mock Get-3parStatVV { Import-Clixml -Path .\Tests\Mock-Get-3parStatVV.xml } -Verifiable

                $Send3ParSys = Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            }

            it 'Should return null' {
                $Send3ParSys | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call Set-3parPoshSshConnectionUsingPasswordFile exactly 1 time' {
                Should -Invoke Set-3parPoshSshConnectionUsingPasswordFile -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-3parSystem exactly 1 time' {
                Should -Invoke Get-3parSystem -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-3parStatVV exactly 1 time' {
                Should -Invoke Get-3parStatVV -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 3 times' {
                Should -Invoke Write-Influx -Exactly -Times 3 -Scope Context
            }
        }

        Context 'Simulating no system data returned' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable

                Mock Get-3parSystem { } -Verifiable

                Mock Get-3parStatVV { }

                $Send3ParSys = Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            }

            It 'Should return null' {
                $Send3ParSys | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call Set-3parPoshSshConnectionUsingPasswordFile exactly 1 time' {
                Should -Invoke Set-3parPoshSshConnectionUsingPasswordFile -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-3parSystem exactly 1 time' {
                Should -Invoke Get-3parSystem -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-3parStatVV exactly 0 times' {
                Should -Invoke Get-3parStatVV -Exactly -Times 0 -Scope Context
            }
            It 'Should call Write-Influx exactly 0 times' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating no volume data returned' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'HPE3PARPSToolkit'} -Verifiable

                Mock Get-3parSystem { Import-Clixml -Path .\Tests\Mock-Get3parSystem.xml } -Verifiable

                Mock Get-3parStatVV { } -Verifiable

                $Send3ParSys = Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd
            }

            It 'Should return null' {
                $Send3ParSys | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call Set-3parPoshSshConnectionUsingPasswordFile exactly 1 time' {
                Should -Invoke Set-3parPoshSshConnectionUsingPasswordFile -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-3parSystem exactly 1 time' {
                Should -Invoke Get-3parSystem -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-3parStatVV exactly 1 times' {
                Should -Invoke Get-3parStatVV -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 0 times' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating module not found' {

            BeforeAll {
                Mock Import-Module { Throw "The specified module 'HPE3PARPSToolkit' was not loaded because no valid module file was found in any module directory." }
            }

            it 'Should throw when the module is not present' {
                { Send-3ParVirtualVolumeMetric -SANIPAddress 1.2.3.4 -SANUsername admin -SANPwdFile C:\scripts\3par.pwd } | Should -Throw "The specified module 'HPE3PARPSToolkit' was not loaded because no valid module file was found in any module directory."
            }
        }
    }
}
