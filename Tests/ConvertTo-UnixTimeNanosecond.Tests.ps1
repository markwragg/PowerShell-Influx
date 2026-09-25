if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "ConvertTo-UnixTimeNanosecond PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            $NewTimeSpan = Get-Command New-TimeSpan

            Mock New-TimeSpan { & $NewTimeSpan -Start $Start -End $End } -Verifiable
        }

        Context 'Date object input' {

            BeforeAll {
                $UnixTime = Get-Date '01/01/2017' | ConvertTo-UnixTimeNanosecond
            }

            It 'Should convert 01/01/2017 to 1483228800000000000' {
                $UnixTime | Should -Be 1483228800000000000
            }
            It "Should return a [long] type value" {
                $UnixTime | Should -BeOfType [long]
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call New-TimeSpan exactly 1 time' {
                Should -Invoke New-TimeSpan -Exactly -Times 1 -Scope Context
            }
        }

        Context 'String object input' {

            BeforeAll {
                $UnixTime = '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeNanosecond
            }

            It "Should convert '01-01-2017 12:34:22.12' to 1483274062120" {
                $UnixTime | Should -Be 1483274062120000000
            }
            It "Should return a [long] type value" {
                $UnixTime | Should -BeOfType [long]
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call New-TimeSpan exactly 1 time' {
                Should -Invoke New-TimeSpan -Exactly -Times 1 -Scope Context
            }
        }
    }
}
