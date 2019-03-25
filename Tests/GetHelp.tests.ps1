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
