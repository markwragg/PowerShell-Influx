if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "Out-InfluxEscapeString PS$PSVersion" {

    $SomeString = 'Some ,string=' | Out-InfluxEscapeString

    It "Should convert 'Some ,string=' to 'Some\ \,string\='" {
        $SomeString | Should -Be 'Some\ \,string\='
    }
    It "Should return a [string] type value" {
        $SomeString | Should -BeOfType [string]
    }
}
