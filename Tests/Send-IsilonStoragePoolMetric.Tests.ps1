if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Send-IsilonStoragePoolMetric PS$PSVersion" {
        
    InModuleScope Influx {
        
        Function New-isiSession { }
        Function Get-isiStoragepools { }
        Function Remove-isiSession { }

        Mock New-isiSession { } -Verifiable
        
        $ImportClixml = Get-Command Import-Clixml
        
        Mock Import-Clixml { } -Verifiable

        Mock Remove-isiSession { } -Verifiable
   
        Mock Write-Influx { }

        Context 'Simulating successful send' {
        
            Mock Import-Module { } -ParameterFilter {$Name -eq 'IsilonPlatform'} -Verifiable
            
            Mock Get-isiStoragepools { & $ImportClixml -Path .\Tests\Mock-GetisiStoragePools.xml } -Verifiable
                    
            $SendIsilonSP = Send-IsilonStoragePoolMetric -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
            
            it 'Should return null' {
                $SendIsilonSP | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call New-isiSession exactly 1 time' {
                Assert-MockCalled New-isiSession -Exactly 1
            }
            It 'Should call Get-isiStoragepools exactly 1 time' {
                Assert-MockCalled Get-isiStoragepools -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 1
            }
            It 'Should call Remove-isiSession exactly 1 time' {
                Assert-MockCalled Remove-isiSession -Exactly 1
            }

        }

        Context 'Simulating no storage pool data returned' {
        
            Mock Import-Module { } -ParameterFilter {$Name -eq 'IsilonPlatform'} -Verifiable
            
            Mock Get-isiStoragepools { } -Verifiable
            
            $SendIsilonSP = Send-IsilonStoragePoolMetric -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab
            
            it 'Should return null' {
                $SendIsilonSP | Should be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call Import-Module exactly 1 time' {
                Assert-MockCalled Import-Module -Exactly 1
            }
            It 'Should call New-isiSession exactly 1 time' {
                Assert-MockCalled New-isiSession -Exactly 1
            }
            It 'Should call Get-isiStoragepools exactly 1 time' {
                Assert-MockCalled Get-isiStoragepools -Exactly 1
            }
            It 'Should call Write-Influx exactly 1 time' {
                Assert-MockCalled Write-Influx -Exactly 0
            }
            It 'Should call Remove-isiSession exactly 1 time' {
                Assert-MockCalled Remove-isiSession -Exactly 1
            }
        }

        Context 'Simulating module not found' {
        
            Mock Import-Module { Throw "The specified module 'IsilonPlatform' was not loaded because no valid module file was found in any module directory." }
        
            it 'Should throw when the module is not present' {
                { Send-IsilonStoragePoolMetric -IsilonName 1.2.3.4 -IsilonPwdFile C:\scripts\Isilon.pwd -ClusterName TestLab } | Should Throw "The specified module 'IsilonPlatform' was not loaded because no valid module file was found in any module directory."
            }
        }        
    }
}