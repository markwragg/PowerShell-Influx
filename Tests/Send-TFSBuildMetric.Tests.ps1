if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-TFSBuildMetric PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            Function Get-TFSBuilds { }

            Mock Write-Influx { }
        }

        Context 'Simulating successful send' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'TFS'} -Verifiable

                Mock Get-TFSBuilds {
                    [PSCustomObject]@{
                        Definition = 'Some def'
                        Result     = 'failed'
                        Duration   = '123'
                        Id         = '456'
                        StartTime  = (Get-Date '01/01/2017 10:00:00')
                    }
                    [PSCustomObject]@{
                        Definition = 'Some def'
                        Result     = 'success'
                        Duration   = '123'
                        Id         = '456'
                        StartTime  = (Get-Date '01/01/2017 10:00:00')
                    }
                } -Verifiable

                $SendTFSBuild = Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject
            }

            it 'Should return null' {
                $SendTFSBuild | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-TFSBuilds exactly 1 time' {
                Should -Invoke Get-TFSBuilds -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 2 times' {
                Should -Invoke Write-Influx -Exactly -Times 2 -Scope Context
            }
        }

        Context 'Simulating successful send with -Latest switch' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'TFS'} -Verifiable

                Mock Get-TFSBuilds {
                    [PSCustomObject]@{
                        Definition = 'Some def'
                        Result     = 'partiallySucceeded'
                        Duration   = '123'
                        Id         = '456'
                        StartTime  = (Get-Date '01/01/2017 10:00:00')
                    }
                } -Verifiable

                $SendTFSBuild = Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject -Latest
            }

            it 'Should return null' {
                $SendTFSBuild | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-TFSBuilds exactly 1 time' {
                Should -Invoke Get-TFSBuilds -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 1 time' {
                Should -Invoke Write-Influx -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating no TFS build data returned' {

            BeforeAll {
                Mock Import-Module { } -ParameterFilter {$Name -eq 'TFS'} -Verifiable

                Mock Get-TFSBuilds { } -Verifiable

                $SendTFSBuild = Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject -Latest -Tags Definition, Id
            }

            It 'Should return null' {
                $SendTFSBuild | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call Import-Module exactly 1 time' {
                Should -Invoke Import-Module -Exactly -Times 1 -Scope Context
            }
            It 'Should call Get-TFSBuilds exactly 1 time' {
                Should -Invoke Get-TFSBuilds -Exactly -Times 1 -Scope Context
            }
            It 'Should call Write-Influx exactly 0 times' {
                Should -Invoke Write-Influx -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating module not found' {

            BeforeAll {
                Mock Import-Module { Throw "The specified module 'TFS' was not loaded because no valid module file was found in any module directory." }
            }

            it 'Should throw when the module is not present' {
                { Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject } | Should -Throw "The specified module 'TFS' was not loaded because no valid module file was found in any module directory."
            }
        }
    }
}
