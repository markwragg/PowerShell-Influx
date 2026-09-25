if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Influx Module Tests PS$PSVersion" {

    BeforeAll {
        $Root = "$PSScriptRoot\.."
        $Module = 'Influx'
    }

    It "Should import without errors" {
        { Import-Module "$Root\$Module" -Force -ErrorAction Stop } | Should -Not -Throw
    }
}
