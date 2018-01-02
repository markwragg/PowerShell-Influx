if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

Get-ChildItem $Root -Filter $Sut -Recurse | ForEach-Object { . $_.FullName }

Describe "ConvertTo-UnixTimeNanosecond PS$PSVersion" {
    
    $NewTimeSpan = Get-Command New-TimeSpan
    
    Mock New-TimeSpan { & $NewTimeSpan -Start $Start -End $End } -Verifiable
        
    Context 'Date object input' {

        $UnixTime = Get-Date '01/01/2017' | ConvertTo-UnixTimeNanosecond

        It 'Should convert 01/01/2017 to 1483228800000000000' {
            $UnixTime | Should Be 1483228800000000000
        }
        It "Should return a [long] type value" {
            $UnixTime | Should BeOfType [long]
        }
        It 'Should execute all verifiable mocks' {
            Assert-VerifiableMock
        }
        It 'Should call New-TimeSpan exactly 1 time' {
            Assert-MockCalled New-TimeSpan -Exactly 1
        }
    } 

    Context 'String object input' {

        $UnixTime = '01-01-2017 12:34:22.12' | ConvertTo-UnixTimeNanosecond

        It "Should convert '01-01-2017 12:34:22.12' to 1483274062120" {
            $UnixTime | Should Be 1483274062120000000
        }
        It "Should return a [long] type value" {
            $UnixTime | Should BeOfType [long]
        }
        It 'Should execute all verifiable mocks' {
            Assert-VerifiableMock
        }
        It 'Should call New-TimeSpan exactly 1 time' {
            Assert-MockCalled New-TimeSpan -Exactly 1
        }
    } 
}
