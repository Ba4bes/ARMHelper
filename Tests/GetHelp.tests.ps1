$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force

Describe 'Check Comment-based help' {
    Context 'All functions should contain Comment-based Help' {
        $Commands = (Get-Module ARMHelper).ExportedCommands

        $TestCases = $Commands.Values | Foreach-Object {
            @{
                Function = $_.Name
            }
        }

        It "<Function> should contain Comment-based Help - Synopsis" -TestCases $TestCases {
            param(
                $Function
            )

            $Help = Get-Help $Function

            $Help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It "<Function> should contain Comment-based Help - Description" -TestCases $TestCases {
            param(
                $Function
            )

            $Help = Get-Help $Function

            $Help.Description | Should -Not -BeNullOrEmpty
        }

        It "<Function> should contain Comment-based Help - Synopsis" -TestCases $TestCases {
            param(
                $Function
            )

            $Examples = Get-Help $Function -Examples

            $Examples | Should -Not -BeNullOrEmpty
        }
    }
}
