if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "Out-InfluxEscapeString PS$PSVersion" {

    Context 'Simulating default escape (-StringType not used)' {

        $SomeString = 'I am a value = "hei, \you\"' | Out-InfluxEscapeString

        It "Should convert 'I am a value = ""hei,\ \you\""'" {
            $SomeString | Should -Be 'I\ am\ a\ value\ \=\ \"hei\,\ \\you\\\"'
        }
        It "Should return a [string] type value" {
            $SomeString | Should -BeOfType [string]
        }
    }

    Context 'Simulating escape of Measurement (-StringType Measurement)' {
        $SomeString = 'AwfulName= \Table,\' | Out-InfluxEscapeString -StringType Measurement

        It "Should return a [string] type value" {
            $SomeString | Should -BeOfType [string]
        }
        It "Should convert 'AwfulName= \Table,\' to 'AwfulName=\ \\Table\,\\'" {
            $SomeString | Should -Be 'AwfulName=\ \\Table\,\\'
        }
    }

    Context 'Simulating escape of Field Text Value (-StringType FieldTextValue)' {
        $SomeString = 'This is a "String" field value' | Out-InfluxEscapeString -StringType FieldTextValue

        It "Should return a [string] type value" {
            $SomeString | Should -BeOfType [string]
        }
        It "Should convert 'This is a ""String"" field value' to 'This is a \""String\"" field value'" {
            $SomeString | Should -Be 'This is a \"String\" field value'
        }
    }
}
