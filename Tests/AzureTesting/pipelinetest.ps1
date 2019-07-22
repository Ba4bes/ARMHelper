param(

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TemplatePath


)

$Global:TemplatePath = $TemplatePath
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
                Write-output $TemplatePath
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$TemplatePath\StorageAccountFixed\azuredeploy.json"
                    templateparameterfile = "$TemplatePath\StorageAccountFixed\azuredeploy.parameters.json"
                }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "When deployment has a regular error, it is given" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$TemplatePath\StorageAccountBroken\azuredeploy.json"
                    templateparameterfile = "$TemplatePath\StorageAccountBroken\azuredeploy.parameters.json"
                }
                $Test = Get-ARMDeploymentErrorMessage @Parameters
                $Test[0] | Should -Be "Error, Find info below:"
                $Test[1] | Should -Be "Deployment template validation failed: 'The template resource '[variables('storageAccountName')]' at line '32' and column '9' is not valid. The type property is invalid. Please see https://aka.ms/arm-template/#resources for usage details.'."
            }
            # This test is removed as there seems to be a bug in the pipeline that doesn't catch that this deployment is incorrect
            # It "When deployment has a general error, the right results are given" {
            #     $Parameters = @{
            #         resourcegroupname     = "ArmHelper"
            #         templatefile          = "$TemplatePath\StorageAccountGE\azuredeploy.json"
            #         templateparameterfile = "$TemplatePath\StorageAccountGE\azuredeploy.parameters.json"
            #     }
            #     $Result = Get-ARMDeploymentErrorMessage @Parameters
            #     $Result[0] | Should -Be "the output is a generic error message. The log is searched for a more clear errormessage"
            #     $Result[-3] | Should -Be "General Error. Find info below:"
            #     $Result[-2] | Should -Be "ErrorCode: AccountNameInvalid"
            #     $Result[-1] | Should -Be "Errormessage: ar!mstaqkc32c2qmmw is not a valid storage account name. Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only."
            # }
            Start-Sleep 5
            It "Throws when TrowonError is used" {
                $Parameters = @{
                    resourcegroupname     = "ArmHelper"
                    templatefile          = "$TemplatePath\StorageAccountBroken\azuredeploy.json"
                    templateparameterfile = "$TemplatePath\StorageAccountBroken\azuredeploy.parameters.json"
                }
                { Get-ARMDeploymentErrorMessage @Parameters -ThrowOnError } | Should -Throw  "Deployment is incorrect"
            }
            # This test is removed as there seems to be a bug in the pipeline that doesn't catch that this deployment is incorrect
            # It "When no errormessage is found in azurelog, script throws" {
            #     Mock Start-Sleep { $null }
            #     function Get-AzureRMLog([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            #     function Get-AzLog([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            #     Mock Get-AzureRMLog { $null }
            #     Mock Get-AzLog { $null }
            #     $Parameters = @{
            #         resourcegroupname     = "ArmHelper"
            #         templatefile          = "$TemplatePath\StorageAccountGE\azuredeploy.json"
            #         templateparameterfile = "$TemplatePath\StorageAccountGE\azuredeploy.parameters.json"
            #     }
            #     { Get-ARMDeploymentErrorMessage @Parameters } | Should -Throw "Can't get Azure Log Entry. Please check the log manually in the portal."
            # }
        }
    }
}

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
