$projectRoot = Resolve-Path "$PSScriptRoot\..\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf
if (Get-Module ARMHelper) {
    Remove-Module -Name ArmHelper -Force
}

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -Force

Describe 'Check Get-ARMDEploymentErrorMessage with Azure' -Tag @("Az") {
    InModuleScope ARMHelper {
        Context 'Basic functionality' {
            It "When a deployment is correct, output is deployment is correct" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountFixed\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountFixed\azuredeploy.parameters.json"
                }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }

            It "Works with a parameterFile"{
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountFixed\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountFixed\azuredeploy.parameters.json"
                }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "works with a parameter object"{
                $Parameterobject = @{
                    storageAccountPrefix = "armsta"
                    storageAccountType = "Standard_LRS"
                }
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountFixed\azuredeploy.json"
                    templateparameterobject = $Parameterobject
                }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }

            It "When deployment has a regular error, it is given" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountBroken\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountBroken\azuredeploy.parameters.json"
                }
                $Test = Get-ARMDeploymentErrorMessage @Parameters
                $Test[0] | Should -Be "Error, Find info below:"
                $Test[1] | Should -Be "Deployment template validation failed: 'The template resource '[variables('storageAccountName')]' at line '32' and column '9' is not valid. The type property is invalid. Please see https://aka.ms/arm-template/#resources for usage details.'."
            }
            It "When deployment has a general error, the right results are given" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountGE\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountGE\azuredeploy.parameters.json"
                }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result[0] | Should -Be "the output is a generic error message. The log is searched for a more clear errormessage"
                $Result[-3] | Should -Be "General Error. Find info below:"
                $Result[-2] | Should -Be "ErrorCode: AccountNameInvalid"
                $Result[-1] | Should -BeLike "* is not a valid storage account name. Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only."
            }
            Start-Sleep 5
            It "Throws when TrowonError is used" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountBroken\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountBroken\azuredeploy.parameters.json"
                }
                { Get-ARMDeploymentErrorMessage @Parameters -ThrowOnError } | Should -Throw  "Deployment is incorrect"
            }
            It "When no errormessage is found in azurelog, script throws" {
                Mock Start-Sleep { $null }
                function Get-AzureRMLog([String]$Name, [Object]$Value, [Switch]$Clobber) { }
                function Get-AzLog([String]$Name, [Object]$Value, [Switch]$Clobber) { }
                Mock Get-AzureRMLog { $null }
                Mock Get-AzLog { $null }
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountGE\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountGE\azuredeploy.parameters.json"
                }
                { Get-ARMDeploymentErrorMessage @Parameters } | Should -Throw "Can't get Azure Log Entry. Please check the log manually in the portal."
            }
        }
    }
}
