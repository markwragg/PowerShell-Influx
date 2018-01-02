if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -File -Recurse | ForEach-Object { . $_.FullName }

Describe "Write-Influx PS$PSVersion" {
    
    Mock Write-Influx { $null }

    $WriteInflux = Write-Influx -Measure WebServer -Tags @{Server='Host01'} -Metrics @{CPU=100; Memory=50} -Database Web -Server http://myinflux.local:8086

    It 'Write-Influx should return null' {
        $WriteInflux | Should -Be $null
    }
}
