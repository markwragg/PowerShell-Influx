if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "ConvertTo-UnixTimeMillisecond PS$PSVersion" {

    Context 'Date object input' {

        $UnixTime = Get-Date '01/01/2017' | ConvertTo-UnixTimeMillisecond

        It 'Should convert 01/01/2017 to 1483228800000' {
            $UnixTime | Should Be 1483228800000
        }
        It "Should return a [double] type value" {
            $UnixTime | Should BeOfType [double]
        }
    } 

    Context 'String object input' {

        $UnixTime = '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeMillisecond

        It "Should convert '01-01-2017 12:34:22.12' to 1508502862120" {
            $UnixTime | Should Be 1483274062120
        }
        It "Should return a [double] type value" {
            $UnixTime | Should BeOfType [double]
        }
    } 
}
