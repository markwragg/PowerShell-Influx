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
                $SomeString | Should -Be 'I\ am\ a\ value\ \=\ "hei\,\ \you\"'
            }
            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
        }

        Context 'Simulating escape of Measurement (-StringType Measurement)' {

            BeforeAll {
                Mock Write-Warning {}
                $SomeString = 'AwfulName= \Table,\' | Out-InfluxEscapeString -StringType Measurement
            }

            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
            It "Should convert 'AwfulName= \Table,\' to 'AwfulName=\ \Table\,\'" {
                $SomeString | Should -Be 'AwfulName=\ \Table\,\'
            }
        }

        Context 'Simulating a tag value containing a backslash, e.g. a Windows path (issue #36)' {

            BeforeAll {
                Mock Write-Warning {}
                $SomeString = 'C:\Windows\Temp' | Out-InfluxEscapeString
            }

            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
            It "Should not double embedded backslashes in 'C:\Windows\Temp'" {
                $SomeString | Should -Be 'C:\Windows\Temp'
            }
            It "Should not warn when the value does not end with a backslash" {
                Should -Invoke Write-Warning -Exactly -Times 0 -Scope Context
            }
        }

        Context 'Simulating a tag value that ends with a backslash, e.g. a bare drive letter (issue #36)' {

            BeforeAll {
                Mock Write-Warning {}
                $SomeString = 'C:\' | Out-InfluxEscapeString
            }

            It "Should return a [string] type value" {
                $SomeString | Should -BeOfType [string]
            }
            It "Should not double the trailing backslash in 'C:\'" {
                $SomeString | Should -Be 'C:\'
            }
            It "Should warn that InfluxDB will reject a value ending in a backslash" {
                Should -Invoke Write-Warning -Exactly -Times 1 -Scope Context
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

        Context 'Simulating a Field Text Value ending with a backslash' {

            BeforeAll {
                Mock Write-Warning {}
                $SomeString = 'hello\' | Out-InfluxEscapeString -StringType FieldTextValue
            }

            It "Should double-escape the trailing backslash to 'hello\\'" {
                $SomeString | Should -Be 'hello\\'
            }
            It "Should not warn, since a quoted field text value can validly end in an escaped backslash" {
                Should -Invoke Write-Warning -Exactly -Times 0 -Scope Context
            }
        }
    }
}
