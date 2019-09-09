if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-TFSBuildMetric PS$PSVersion" {
        
    InModuleScope Influx {
        
        Function Get-TFSBuilds { }

        Mock Write-Influx { }

        Context 'Simulating successful send' {
            
            Mock Import-Module { } -ParameterFilter {$Name -eq 'TFS'} -Verifiable
         
            Mock Get-TFSBuilds { 
                [PSCustomObject]@{
                    Definition = 'Some def'
                    Result     = 'failed'
                    Duration   = '123'
                    Id         = '456'
                    StartTime  = (Get-Date '01/01/2017 10:00:00')
                }
                [PSCustomObject]@{
                    Definition = 'Some def'
                    Result     = 'success'
                    Duration   = '123'
                    Id         = '456'
                    StartTime  = (Get-Date '01/01/2017 10:00:00')
                }
            } -Verifiable

            $SendTFSBuild = Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject
            
            it 'Should return null' {
                $SendTFSBuild | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call Get-TFSBuilds exactly 1 time' {
                Assert-MockCalled Get-TFSBuilds -Exactly 1
            }
            It 'Should call Write-Influx exactly 2 times' {
                Assert-MockCalled Write-Influx -Exactly 2
            }  
        }

        Context 'Simulating successful send with -Latest switch' {
            
            Mock Import-Module { } -ParameterFilter {$Name -eq 'TFS'} -Verifiable
         
            Mock Get-TFSBuilds { 
                [PSCustomObject]@{
                    Definition = 'Some def'
                    Result     = 'partiallySucceeded'
                    Duration   = '123'
                    Id         = '456'
                    StartTime  = (Get-Date '01/01/2017 10:00:00')
                }
            } -Verifiable

            $SendTFSBuild = Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject -Latest
            
            it 'Should return null' {
                $SendTFSBuild | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call Get-TFSBuilds exactly 1 time' {
                Assert-MockCalled Get-TFSBuilds -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }  
        }

        Context 'Simulating no TFS build data returned' {
        
            Mock Import-Module { } -ParameterFilter {$Name -eq 'TFS'} -Verifiable
            
            Mock Get-TFSBuilds { } -Verifiable
            
            $SendTFSBuild = Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject -Latest -Tags Definition, Id
            
            It 'Should return null' {
                $SendTFSBuild | Should be $null
            }  
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call Get-TFSBuilds exactly 1 time' {
                Assert-MockCalled Get-TFSBuilds -Exactly 1
            }
            It 'Should call Write-Influx exactly 0 times' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
        }

        Context 'Simulating module not found' {
        
            Mock Import-Module { Throw "The specified module 'TFS' was not loaded because no valid module file was found in any module directory." }
        
            it 'Should throw when the module is not present' {
                { Send-TFSBuildMetric -TFSRootURL https://localhost:8088/tfs -TFSCollection MyCollection -TFSProject MyProject } | Should Throw "The specified module 'TFS' was not loaded because no valid module file was found in any module directory."
            }
        }       
    }
}