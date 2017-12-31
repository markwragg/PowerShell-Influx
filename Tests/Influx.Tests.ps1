$here = $PSScriptRoot
$sut = Get-ChildItem "$here\..\Influx\*.ps1" -Recurse -File
$sut | ForEach-Object { . $_.FullName }

Describe 'Isilon Module Tests' {
    It "Should import without errors" {
        {Import-Module $here\..\Influx\Influx.psd1 -ErrorAction Stop} | Should Not Throw
    }
}
