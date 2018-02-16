if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "ConvertTo-StatsDString PS$PSVersion" {
        
    Context 'Metric object input' {

        $MeasureObject = [pscustomobject]@{
            PSTypeName = 'Metric'
            Measure    = 'SomeMeasure'
            Metrics    = @{One = 'One'; Two = 2}
            Tags       = @{TagOne = 'One'; TagTwo = 2}
            TimeStamp  = (Get-Date)
        }
        
        $StatsD = $MeasureObject | ConvertTo-StatsDString

        It 'Should return a string' {
            $StatsD | Should BeOfType [String]
        }
    } 

    Context 'String object input' {

    } 
}
