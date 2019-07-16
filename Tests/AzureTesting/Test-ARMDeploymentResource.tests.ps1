$projectRoot = Resolve-Path "$PSScriptRoot\..\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf
if (Get-Module ARMHelper) {
    Remove-Module -Name ARMHelper -Force
}
Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -Force


Describe 'Check Test-ARMDeploymentResource with Azure' -Tag @("Az") {
    InModuleScope ARMHelper {
        $Parameters = @{
            resourcegroupname     = "ArmHelper"
            templatefile          = "$PSScriptRoot\VirtualMachine\azuredeploy.json"
            templateparameterfile = "$PSScriptRoot\VirtualMachine\azuredeploy.parameters.json"
        }
        Context 'Basic functionallity' {
            It "When a deployment is correct, script doesn't throw" {
                { Test-ARMDeploymentResource @Parameters } | Should -Not -Throw
            }
            It "Shows standard properties for resources that would be in the deployment" {
                $Result = Test-ARMDeploymentResource @Parameters
                $Result[0].Resource | Should -be "StorageAccounts"
                $Result[0].Name | Should -be "mstaqkc32c2qmmw"
                $Result[0].Type | Should -be "Microsoft.Storage/storageAccounts"
                $Result[0].Location | Should -be "westeurope"
                $Result[0].mode | Should -be "Incremental"
                $Result[0].ID | Should -BeLike "*/resourceGroups/ArmHelper/providers/Microsoft.Storage/storageAccounts/mstaqkc32c2qmmw"
                $Result[0].kind | Should -be "Storage"
                $Result[0].sku.name | Should -BeNullOrEmpty
            }
            It "Shows all properties when using Select-Object *" {
                $Result = Test-ARMDeploymentResource @Parameters | Select-Object *
                $result[0].'.sku.name' | Should -be "Standard_LRS"
                $Result[0].apiVersion | Should -be "2018-11-01"
            }
            it "When a parameter is a securestring, it is shown as a securestring in the output" {
                $Result = Test-ARMDeploymentResource @Parameters
                $Result[-1].adminPassword | Should -Be "System.Security.SecureString"
            }
            it "Should throw when no result is found" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$PSScriptRoot\StorageAccountBroken\azuredeploy.json"
                    templateparameterfile = "$PSScriptRoot\StorageAccountBroken\azuredeploy.parameters.json"
                }
                { Test-ARMDeploymentResource @Parameters } | Should throw "Something is wrong with the output, no resources found. Please check your deployment with Get-ARMdeploymentErrorMessage"
            }
        }
    }
}
