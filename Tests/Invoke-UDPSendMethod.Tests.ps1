if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Invoke-UDPSendMethod PS$PSVersion" {
    
    InModuleScope Influx {
        
        $NewObject = Get-Command New-Object

        Mock New-Object { & $NewObject -TypeName $TypeName -ArgumentList $ArgumentList -Property $Property } -Verifiable

        Context 'Simulating successful write' {
            
            Mock Write-Verbose { $null }

            $InvokeUDPSend = 'my_metric:1|c' | Invoke-UDPSendMethod -IP 1.2.3.4 -Port 1234

            It 'Invoke-UDPSendMethod should return null' {
                $InvokeUDPSend | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call New-Object exactly 2 times' {
                Assert-MockCalled New-Object -Exactly 2
            }
            It 'Should call Write-Verbose exactly 1 times' {
                Assert-MockCalled Write-Verbose -Exactly 1
            }
        }

        Context 'Simulating -WhatIf' {
       
            Mock Write-Verbose { $null } -ParameterFilter {$WhatIf -eq $true}
           
            $InvokeUDPSend = 'my_metric:1|c' | Invoke-UDPSendMethod -IP 1.2.3.4 -Port 1234 -WhatIf

            It 'Invoke-UDPSendMethod should return null' {
                $InvokeUDPSend | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Assert-VerifiableMock
            }
            It 'Should call New-Object exactly 2 times' {
                Assert-MockCalled New-Object -Exactly 2
            }
            It 'Should call Write-Verbose exactly 0 times' {
                Assert-MockCalled Write-Verbose -Exactly 0
            }
        }
    }
}