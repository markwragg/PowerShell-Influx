$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$root = "$here\..\"
Get-ChildItem $root -Recurse | Where-Object { $_.Name -eq $sut } | ForEach-Object { . $_.FullName }

Describe 'Out-InfluxEscapeString' {
    $SomeString = 'Some ,string=' | Out-InfluxEscapeString

    It "Should convert 'Some ,string=' to 'Some\ \,string\='" {
        $SomeString | Should Be 'Some\ \,string\='
    }
}
