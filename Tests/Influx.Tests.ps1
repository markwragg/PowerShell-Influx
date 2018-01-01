$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = "$here\..\Influx"

Describe 'Isilon Module Tests' {
    It "Should import without errors" {
        {Import-Module $root\Influx.psd1 -ErrorAction Stop} | Should Not Throw
    }
}
