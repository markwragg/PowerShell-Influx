if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Format-InfluxFieldValue PS$PSVersion" {

    InModuleScope Influx {

        Context 'Simulating a numeric metric value' {

            BeforeAll {
                Mock Write-Warning {}
                $Result = 100 | Format-InfluxFieldValue
            }

            It "Should return the number unchanged" {
                $Result | Should -Be 100
            }
            It "Should not warn" {
                Should -Invoke Write-Warning -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating a boolean metric value' {

            BeforeAll {
                Mock Write-Warning {}
                $Result = $true | Format-InfluxFieldValue
            }

            It "Should return the boolean unquoted (InfluxDB does not permit quoted booleans)" {
                $Result | Should -Be 'True'
            }
            It "Should not warn" {
                Should -Invoke Write-Warning -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating a string metric value containing characters that need escaping' {

            BeforeAll {
                $Result = 'has "quotes" and \back\slash' | Format-InfluxFieldValue
            }

            It "Should quote the value and escape embedded quotes/backslashes" {
                $Result | Should -Be '"has \"quotes\" and \\back\\slash"'
            }
        }

        Context 'Simulating a datetime metric value (issue #16)' {

            BeforeAll {
                Mock ConvertTo-UnixTimeNanosecond { 1483274062120000000 }
                $Result = (Get-Date) | Format-InfluxFieldValue
            }

            It "Should convert it to a Unix nanosecond integer field" {
                $Result | Should -Be '1483274062120000000i'
            }
            It "Should call ConvertTo-UnixTimeNanosecond exactly 1 time" {
                Should -Invoke ConvertTo-UnixTimeNanosecond -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating a metric value with no meaningful ToString() representation (issue #16)' {

            BeforeAll {
                Mock Write-Warning {}
                Add-Type -TypeDefinition 'public class FormatInfluxFieldValueTestType {}' -ErrorAction SilentlyContinue
                $Complex = New-Object FormatInfluxFieldValueTestType
                $Result = $Complex | Format-InfluxFieldValue
            }

            It "Should quote the type name as a fallback string value" {
                $Result | Should -Be '"FormatInfluxFieldValueTestType"'
            }
            It "Should warn that the value has no meaningful ToString()" {
                Should -Invoke Write-Warning -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating a null metric value' {

            It "Should not throw" {
                { $null | Format-InfluxFieldValue } | Should -Not -Throw
            }
        }
    }
}
