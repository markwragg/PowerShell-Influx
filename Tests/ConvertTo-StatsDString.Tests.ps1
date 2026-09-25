if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "ConvertTo-StatsDString PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            $MeasureObject = [pscustomobject]@{
                PSTypeName = 'Metric'
                Measure    = 'SomeMeasure'
                Metrics    = @{One = 'One'; Two = 2}
                Tags       = @{TagOne = 'One'; TagTwo = 2}
                TimeStamp  = (Get-Date)
            }
        }

        Context 'Metric object input' {

            BeforeAll {
                $StatsD = $MeasureObject | ConvertTo-StatsDString
            }

            It 'Should return a string' {
                $StatsD | Should -BeOfType [String]
            }
            It 'Should return two StatsD formmated strings' {
                $StatsD[0] | Should -Be 'SomeMeasure.One,TagOne=One,TagTwo=2:One|g'
                $StatsD[1] | Should -Be 'SomeMeasure.Two,TagOne=One,TagTwo=2:2|g'
            }
        }

        Context '-Type specified as c' {

            BeforeAll {
                $StatsD = $MeasureObject | ConvertTo-StatsDString -Type 'c'
            }

            It 'Should return a string' {
                $StatsD | Should -BeOfType [String]
            }
            It 'Should return two StatsD formmated strings with the type set to c' {
                $StatsD[0] | Should -Be 'SomeMeasure.One,TagOne=One,TagTwo=2:One|c'
                $StatsD[1] | Should -Be 'SomeMeasure.Two,TagOne=One,TagTwo=2:2|c'
            }
        }
    }
}
