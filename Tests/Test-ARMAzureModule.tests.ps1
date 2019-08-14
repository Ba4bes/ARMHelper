$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force


Describe 'Test-ARMAzureModule' -Tag @("Mock") {
    InModuleScope ARMHelper {
        Context 'When module is not loaded' {
            It "If none are available, script should throw" {
                Mock Get-InstalledModule -MockWith { $null }
                Mock Get-Module -MockWith { $null }
                { Test-ARMAzureModule } | Should -Throw "neither AZ of AzureRM could be loaded"

            }
            function Get-AzContext  ([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            function Get-AzureRMContext([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            Mock Get-Module { $null }
            Mock Import-Module { $null }
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
            Mock Get-AzContext -MockWith { "no error" }
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
                Mock Import-Module -MockWith { "no error" }
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
        }
        Context 'When module is loaded' {
            function Get-AzContext  ([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            function Get-AzureRMContext([String]$Name, [Object]$Value, [Switch]$Clobber) { }

            Mock Get-AzureRmContext -MockWith { "no error" }
            It "If AzureRM is already loaded, output should be AzureRM" {
                Mock Get-InstalledModule -MockWith {
                    $null
                }
                Mock Get-Module -MockWith {
                    $null
                } -ParameterFilter { $Name -eq "Az.*" }
                Mock Get-Module -MockWith {
                    [array]@(
                        "module1",
                        "Module2"
                    )
                } -ParameterFilter { $Name -eq "AzureRM.*" }
                $Result = Test-ARMAzureModule
                $Result | Should -be "AzureRM"
            }
            It "If Az is already loaded, output should be Az" {
                Mock Get-InstalledModule -MockWith {
                    $null
                }
                Mock Get-Module -MockWith {
                    $null
                } -ParameterFilter { $Name -eq "AzureRM.*" }
                Mock Get-Module -MockWith {
                    [array]@(
                        "module1",
                        "Module2"
                    )
                } -ParameterFilter { $Name -eq "Az.*" }

                Mock Get-AzContext -MockWith { "no error" }

                $Result = Test-ARMAzureModule
                $Result | Should -be "Az"
            }

        }
    }
}