$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = "$here\..\Influx"

$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Influx Module Tests PS$PSVersion" {
  
    It "Should import without errors" {
        {Import-Module $root\Influx.psd1 -Force -ErrorAction Stop} | Should Not Throw
    }
}
