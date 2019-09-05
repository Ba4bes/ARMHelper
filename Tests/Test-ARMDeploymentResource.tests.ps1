$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force


Describe 'Check Test-ARMDeploymentResource without Azure' -Tag @("Mock") {
    InModuleScope ARMHelper {
        $Parameters = @{
            resourcegroupname     = "Arm"
            templatefile          = "$PSScriptRoot\MockObjects\azuredeploy.json"
            templateparameterfile = ".\azuredeploy.parameters.json"
        }
        Context 'Basic functionallity' {
            $Mockobject = (Get-Content "$PSScriptRoot\MockObjects\Result.json") | ConvertFrom-Json
            Mock Get-ARMResource {
                [object]$Mockobject
            }

            It "Works with a parameterFile" {
                { Test-ARMDeploymentResource @Parameters } | Should -Not -Throw
            }
            It "works with a parameter object" {
                $Parameterobject = @{
                    storageAccountPrefix = "armsta"
                    storageAccountType   = "LRS"
                }
                $Parameters = @{
                    resourcegroupname       = "Arm"
                    templatefile            = "$PSScriptRoot\MockObjects\azuredeploy.json"
                    templateparameterobject = $Parameterobject
                }
                { Test-ARMDeploymentResource @Parameters } | Should -Not -Throw

            }
            It "works with added Parameters" {
                $Parameters = @{
                    resourcegroupname    = "Arm"
                    templatefile         = "$PSScriptRoot\MockObjects\azuredeploy.json"
                    storageAccountPrefix = "armsta"
                    storageAccountType   = "LRS"
                }
                { Test-ARMDeploymentResource @Parameters } | Should -Not -Throw
            }

            It "When a deployment is correct, script doesn't throw" {
                { Test-ARMDeploymentResource @Parameters } | Should -Not -Throw
            }
            It "Shows standard properties for resources that would be in the deployment" {
                $Result = Test-ARMDeploymentResource @Parameters
                $Result[0].Resource | Should -be "StorageAccounts"
                $Result[0].Name | Should -be "qkc32cvb2qmmwsawinvm"
                $Result[0].Type | Should -be "Microsoft.Storage/storageAccounts"
                $Result[0].Location | Should -be "westeurope"
                $Result[0].mode | Should -be "Incremental"
                $Result[0].ID | Should -be "/subscriptions/12345678-abcd-1234-1234-12345678/resourceGroups/armtesting/providers/Microsoft.Storage/storageAccounts/qkc32cvb2qmmwsawinvm"
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
                Mock Get-ARMResource { $null }
                { Test-ARMDeploymentResource @Parameters } | Should throw "Something is wrong with the output, no resources found. Please check your deployment with Get-ARMdeploymentErrorMessage"
            }
            It "All Mocks are called" {
                Assert-MockCalled -CommandName Get-ARMResource
            }
        }
    }
}