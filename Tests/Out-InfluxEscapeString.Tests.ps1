if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Out-InfluxEscapeString PS$PSVersion" {

    InModuleScope Influx {

        Context 'Simulating default escape (-StringType not used)' {

            BeforeAll {
                $SomeString = 'I am a value = "hei, \you\"' | Out-InfluxEscapeString
            }

            It "Should convert 'I am a value = ""hei,\ \you\""'" {
                $SomeString | Should -Be 'I\ am\ a\ value\ \=\ \"hei\,\ \\you\\\"'
            }
            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
        }

        Context 'Simulating escape of Measurement (-StringType Measurement)' {

            BeforeAll {
                $SomeString = 'AwfulName= \Table,\' | Out-InfluxEscapeString -StringType Measurement
            }

            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
            It "Should convert 'AwfulName= \Table,\' to 'AwfulName=\ \\Table\,\\'" {
                $SomeString | Should -Be 'AwfulName=\ \\Table\,\\'
            }
        }

        Context 'Simulating escape of Field Text Value (-StringType FieldTextValue)' {

            BeforeAll {
                $SomeString = 'This is a "String" field value' | Out-InfluxEscapeString -StringType FieldTextValue
            }

            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
            It "Should convert 'This is a ""String"" field value' to 'This is a \""String\"" field value'" {
                $SomeString | Should -Be 'This is a \"String\" field value'
            }
        }
    }
}
