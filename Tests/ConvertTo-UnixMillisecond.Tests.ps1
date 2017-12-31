$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Influx\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }

Describe 'ConvertTo-UnixTimeMillisecond Tests' {
    $UnixTime = Get-Date "01/01/2017" | ConvertTo-UnixTimeMillisecond

    It "Should convert 01/01/2017 to 1483228800000" {
        $UnixTime | Should Be 1483228800000
    }
}
