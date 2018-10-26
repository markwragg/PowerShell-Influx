if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "ConvertTo-Metric PS$PSVersion" {
      
    $SomeObject = @(
        [pscustomobject]@{
            Name      = 'Test'
            SomeValue = 1
        },
        [pscustomobject]@{
            Name      = 'Other'
            SomeValue = 20
        }
    )

    $MetricObject = $SomeObject | ConvertTo-Metric -Measure Test -MetricProperty Name,SomeValue

    It 'Should return Metric objects' {
        $MetricObject | ForEach-Object {
            $_.PSObject.TypeNames | Should -Contain 'Metric'
        }
    }      
    It 'Should return two objects' {
        $MetricObject.count | Should -Be 2
    }    
} 
