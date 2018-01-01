$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$root = "$here\..\"
Get-ChildItem $root -Recurse | Where-Object { $_.Name -eq $sut } | ForEach-Object { . $_.FullName }

Describe 'ConvertTo-UnixTimeMillisecond' {
    $UnixTime = Get-Date "01/01/2017" | ConvertTo-UnixTimeMillisecond

    It "Should convert 01/01/2017 to 1483228800000" {
        $UnixTime | Should Be 1483228800000
    }
}
