if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Describe "Influx Module Tests PS$PSVersion" {
  
    It "Should import without errors" {
        {Import-Module "$Root\$Module" -Force -ErrorAction Stop} | Should -Not -Throw
    }
}
