if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\..\"
$Module = 'Influx'

Get-Module $Module | Remove-Module -Force

Import-Module "$Root\$Module" -Force

Describe "Invoke-UDPSendMethod PS$PSVersion" {

    InModuleScope Influx {

        BeforeAll {
            $NewObject = Get-Command New-Object

            Mock New-Object { & $NewObject -TypeName $TypeName -ArgumentList $ArgumentList -Property $Property } -Verifiable
        }

        Context 'Simulating successful write' {

            BeforeAll {
                Mock Write-Verbose { $null }

                $InvokeUDPSend = 'my_metric:1|c' | Invoke-UDPSendMethod -IP 1.2.3.4 -Port 1234
            }

            It 'Invoke-UDPSendMethod should return null' {
                $InvokeUDPSend | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call New-Object exactly 2 times' {
                Should -Invoke New-Object -Exactly -Times 2 -Scope Context
            }
            It 'Should call Write-Verbose exactly 1 times' {
                Should -Invoke Write-Verbose -Exactly -Times 1 -Scope Context
            }
        }

        Context 'Simulating -WhatIf' {

            BeforeAll {
                Mock Write-Verbose { $null } -ParameterFilter {$WhatIf -eq $true}

                $InvokeUDPSend = 'my_metric:1|c' | Invoke-UDPSendMethod -IP 1.2.3.4 -Port 1234 -WhatIf
            }

            It 'Invoke-UDPSendMethod should return null' {
                $InvokeUDPSend | Should -Be $null
            }
            It 'Should execute all verifiable mocks' {
                Should -InvokeVerifiable
            }
            It 'Should call New-Object exactly 2 times' {
                Should -Invoke New-Object -Exactly -Times 2 -Scope Context
            }
            It 'Should call Write-Verbose exactly 0 times' {
                Should -Invoke Write-Verbose -Exactly -Times 0 -Scope Context
            }
        }
    }
}
