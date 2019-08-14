$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force


Describe 'When AzureRM is available' -Tag @("Mock") {
    InModuleScope ARMHelper {
        Context 'Basic functionality' {
            function Get-AzContext  ([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            function Get-AzureRMContext([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            Mock Get-InstalledModule -MockWith {
                [pscustomobject]@{
                    "Version"     = "6.13.1"
                    "Name"        = "AzureRM"
                    "Repository"  = "PSGallery"
                    "Description" = "Azure Resource Manager Module"
                }
            } -ParameterFilter { $Name -eq "AzureRM" }
            Mock Get-InstalledModule -MockWith {
                $null
            } -ParameterFilter { $Name -eq "Az" }
            Mock Get-AzureRmContext -MockWith { "no error" }

            It "If Only AzureRM is available, output should be AzureRM" {
                $Result = Test-ARMAzureModule
                $Result | Should -be "AzureRM"
            }
            It "If Only Az is available, output should be Az" {
                Mock Get-InstalledModule -MockWith {
                    $null
                } -ParameterFilter { $Name -eq "AzureRM" }
                Mock Get-InstalledModule -MockWith {
                    [pscustomobject]@{
                        "Version"     = "2.4.0"
                        "Name"        = "Az"
                        "Repository"  = "PSGallery"
                        "Description" = "Azure Resource Manager Module"
                    }
                } -ParameterFilter { $Name -eq "Az" }
                Mock Get-AzContext -MockWith { "no error" }

                $Result = Test-ARMAzureModule
                $Result | Should -be "Az"
            }
            It "If Both are available, output should be Az" {
                Mock Get-InstalledModule -MockWith {
                    [pscustomobject]@{
                        "Version"     = "6.13.1"
                        "Name"        = "AzureRM"
                        "Repository"  = "PSGallery"
                        "Description" = "Azure Resource Manager Module"
                    }
                } -ParameterFilter { $Name -eq "AzureRM" }
                Mock Get-InstalledModule -MockWith {
                    [pscustomobject]@{
                        "Version"     = "2.4.0"
                        "Name"        = "Az"
                        "Repository"  = "PSGallery"
                        "Description" = "Azure Resource Manager Module"
                    }
                } -ParameterFilter { $Name -eq "Az" }
                $Result = Test-ARMAzureModule
                $Result | Should -be "Az"
            }
            It "If none are available, script should throw" {
                Mock Get-InstalledModule -MockWith {
                    $null
                } -ParameterFilter { $Name -eq "Az" }
                Mock Get-InstalledModule -MockWith {
                    $null
                } -ParameterFilter { $Name -eq "AzureRM" }

                { Test-ARMAzureModule } | Should -Throw "neither AZ of AzureRM could be loaded"

            }
            It "If Connection with Azure can't be made, script should throw" {
                Mock Get-InstalledModule -MockWith {
                    [pscustomobject]@{
                        "Version"     = "6.13.1"
                        "Name"        = "AzureRM"
                        "Repository"  = "PSGallery"
                        "Description" = "Azure Resource Manager Module"
                    }
                } -ParameterFilter { $Name -eq "AzureRM" }
                Mock Get-AzureRMContext -MockWith { Throw "error" }
                { Test-ARMAzureModule } | Should -Throw "No connection with AzureRM has been found. Please Connect."

                Mock Get-InstalledModule -MockWith {
                    [pscustomobject]@{
                        "Version"     = "2.4.0"
                        "Name"        = "Az"
                        "Repository"  = "PSGallery"
                        "Description" = "Azure Resource Manager Module"
                    }
                } -ParameterFilter { $Name -eq "Az" }
                Mock Get-AzContext -MockWith { Throw "error" }
                { Test-ARMAzureModule } | Should -Throw "No connection with Az has been found. Please Connect."
            }
        }
    }
}