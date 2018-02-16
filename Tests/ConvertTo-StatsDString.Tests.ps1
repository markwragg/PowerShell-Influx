if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "ConvertTo-StatsDString PS$PSVersion" {
      
    $MeasureObject = [pscustomobject]@{
        PSTypeName = 'Metric'
        Measure    = 'SomeMeasure'
        Metrics    = @{One = 'One'; Two = 2}
        Tags       = @{TagOne = 'One'; TagTwo = 2}
        TimeStamp  = (Get-Date)
    }
    
    Context 'Metric object input' {

        $StatsD = $MeasureObject | ConvertTo-StatsDString

        It 'Should return a string' {
            $StatsD | Should -BeOfType [String]
        }
        It 'Should return two StatsD formmated strings' {
            $StatsD[0] | Should -Be 'SomeMeasure.One,TagOne=One,TagTwo=2:One|g'
            $StatsD[1] | Should -Be 'SomeMeasure.Two,TagOne=One,TagTwo=2:2|g'
        }        
    }

    Context '-Type specified as c' {
        
        $StatsD = $MeasureObject | ConvertTo-StatsDString -Type 'c'
    
        It 'Should return a string' {
            $StatsD | Should -BeOfType [String]
        }
        It 'Should return two StatsD formmated strings with the type set to c' {
            $StatsD[0] | Should -Be 'SomeMeasure.One,TagOne=One,TagTwo=2:One|c'
            $StatsD[1] | Should -Be 'SomeMeasure.Two,TagOne=One,TagTwo=2:2|c'
        }
    }
} 
