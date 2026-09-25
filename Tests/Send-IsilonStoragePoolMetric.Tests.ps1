if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-IsilonStoragePoolMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function New-isiSession { }
            Function Get-isiStoragepools { }
            Function Remove-isiSession { }

            Mock New-isiSession { } -Verifiable

            $ImportClixml = Get-Command Import-Clixml

            Mock Import-Clixml { } -Verifiable

            Mock Remove-isiSession { } -Verifiable

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'IsilonPlatform'} -Verifiable

                Mock Get-isiStoragepools { & $ImportClixml -Path .\Tests\Mock-GetisiStoragePools.xml } -Verifiable

                $SendIsilonSP = Send-IsilonStoragePoolMetric -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
            }

            it 'Should return null' {
                $SendIsilonSP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call New-isiSession exactly 1 time' {
                Should -Invoke New-isiSession -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-isiStoragepools exactly 1 time' {
                Should -Invoke Get-isiStoragepools -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
            It 'Should call Remove-isiSession exactly 1 time' {
                Should -Invoke Remove-isiSession -Exactly -Times 1 -Scope Context
            }

        }

        Context 'Simulating no storage pool data returned' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'IsilonPlatform'} -Verifiable

                Mock Get-isiStoragepools { } -Verifiable

                $SendIsilonSP = Send-IsilonStoragePoolMetric -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
            }

            it 'Should return null' {
                $SendIsilonSP | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call New-isiSession exactly 1 time' {
                Should -Invoke New-isiSession -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-isiStoragepools exactly 1 time' {
                Should -Invoke Get-isiStoragepools -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
            It 'Should call Remove-isiSession exactly 1 time' {
                Should -Invoke Remove-isiSession -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating module not found' {

            BeforeAll {
                Mock Import-Module { Throw "The specified module 'IsilonPlatform' was not loaded because no valid module file was found in any module directory." }
            }

            it 'Should throw when the module is not present' {
                { Send-IsilonStoragePoolMetric -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab } | Should -Throw "The specified module 'IsilonPlatform' was not loaded because no valid module file was found in any module directory."
            }
        }
    }
}
