if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."

Describe "Influx Module Tests PS$PSVersion" {
  
    It "Should import without errors" {
        {Import-Module "$Root\Influx" -Force -ErrorAction Stop} | Should -Not -Throw
    }
}
