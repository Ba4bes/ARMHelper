$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force


Describe 'Check Test-ARMExistingResource without Azure' -Tag @("Mock") {

    InModuleScope ARMHelper {
        Context 'AZ Incremental' {
            function Get-AzResource([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            $Parameters = @{
                resourcegroupname     = "Arm"
                templatefile          = "$PSScriptRoot\MockObjects\azuredeploy.json"
                templateparameterfile = ".\azuredeploy.parameters.json"
                Mode                  = "Incremental"
            }
            Mock Test-ARMAzureModule { "Az" }
            $Mockobject = (Get-Content "$PSScriptRoot\MockObjects\Result.json") | ConvertFrom-Json
            Mock Get-ARMResource {
                [object]$Mockobject
            }
            It "When all resources are new, output shows they will be created" {
                Mock Get-AzResource { $null }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Incremental `n"
                $Result[1] | Should -Be "The following resources do not exist and will be created:"
                $Result[2].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[2].ResourceGroupName | Should -Be "Arm"
            }
            It "When resources already exist and mode is incremental, they will be shown as so" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResources.json") | ConvertFrom-Json
                Mock Get-AzResource {
                    [object]$MockAZResource
                }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Incremental `n"
                $Result[1] | Should -Be "The following resources exist. Mode is set to incremental. New properties might be added:"
                $Result[2].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[2].ResourceGroupName | Should -Be "Arm"
            }
        }
        Context 'Az Complete ' {
            function Get-AzResource([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            $Parameters = @{
                resourcegroupname     = "Arm"
                templatefile          = "$PSScriptRoot\MockObjects\azuredeploy.json"
                templateparameterfile = ".\azuredeploy.parameters.json"
                Mode                  = "Complete"
            }
            $Mockobject = (Get-Content "$PSScriptRoot\MockObjects\ResultComplete.json") | ConvertFrom-Json
            Mock Get-ARMResource {
                [object]$Mockobject
            }
            Mock Test-ARMAzureModule { "Az" }
            It "When resources would be overwritten, they are shown as overwritten" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResources.json") | ConvertFrom-Json
                Mock Get-AzResource {
                    [object]$MockAZResource
                }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Complete `n"
                $Result[1] | Should -Be "THE FOLLOWING RESOURCES WILL BE OVERWRITTEN! `n Resources exist and mode is complete:"
                $Result[2].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[2].ResourceGroupName | Should -Be "Arm"
            }
            it "When resources would be deleted, they are shown as deleted" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResourcesDeleted.json") | ConvertFrom-Json
                Mock Get-AzResource {
                    [object]$MockAZResource
                }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Complete `n"
                $Result[8] | Should -Be "THE FOLLOWING RESOURCES WILL BE DELETED! `n Resources exist in the resourcegroup but not in the template, mode is complete:"
                $Result[9].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[9].ResourceGroupName | Should -Be "Arm"
            }
            it "When ThrowWhenRemoving is used, it will throw if resources are deleted" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResourcesDeleted.json") | ConvertFrom-Json
                Mock Get-AzResource {
                    [object]$MockAZResource
                }
                { Test-ARMExistingResource @Parameters -ThrowWhenRemoving } | Should throw
            }
            it "When ThrowWhenRemoving is used, but  nothing would be overwritten, it will not throw" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResources.json") | ConvertFrom-Json
                Mock Get-AzResource {
                    [object]$MockAZResource
                }
                { Test-ARMExistingResource @Parameters -ThrowWhenRemoving } | Should throw
            }
            it "Should throw when no result is found" {
                Mock Get-ARMResource { $null }
                { Test-ARMExistingResource @Parameters } | Should throw "Something is wrong with the output, no resources found. Please check your deployment with Get-ARMdeploymentErrorMessage"
            }
            It "Mocks are called" {
                Assert-MockCalled -CommandName Get-ARMResource
                Assert-MockCalled -CommandName Get-AZResource
            }
        }


        Context 'AzureRM Incremental' {
            function Get-AzureRMResource([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            $Parameters = @{
                resourcegroupname     = "Arm"
                templatefile          = "$PSScriptRoot\MockObjects\azuredeploy.json"
                templateparameterfile = ".\azuredeploy.parameters.json"
                Mode                  = "Incremental"
            }
            Mock Test-ARMAzureModule { "AzureRM" }
            $Mockobject = (Get-Content "$PSScriptRoot\MockObjects\Result.json") | ConvertFrom-Json
            Mock Get-ARMResource {
                [object]$Mockobject
            }
            It "When all resources are new, output shows they will be created" {

                Mock Get-AzureRMResource { $null }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Incremental `n"
                $Result[1] | Should -Be "The following resources do not exist and will be created:"
                $Result[2].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[2].ResourceGroupName | Should -Be "Arm"
            }
            It "When resources already exist and mode is incremental, they will be shown as so" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResources.json") | ConvertFrom-Json
                Mock Get-AzureRMResource {
                    [object]$MockAZResource
                }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Incremental `n"
                $Result[1] | Should -Be "The following resources exist. Mode is set to incremental. New properties might be added:"
                $Result[2].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[2].ResourceGroupName | Should -Be "Arm"

            }
        }
        Context 'Complete ' {

            function Get-AzureRMResource([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            $Parameters = @{
                resourcegroupname     = "Arm"
                templatefile          = "$PSScriptRoot\MockObjects\azuredeploy.json"
                templateparameterfile = ".\azuredeploy.parameters.json"
                Mode                  = "Complete"
            }
            $Mockobject = (Get-Content "$PSScriptRoot\MockObjects\ResultComplete.json") | ConvertFrom-Json
            Mock Get-ARMResource {
                [object]$Mockobject
            }
            Mock Test-ARMAzureModule { "AzureRM" }
            It "When resources would be overwritten, they are shown as overwritten" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResources.json") | ConvertFrom-Json
                Mock Get-AzureRMResource {
                    [object]$MockAZResource
                }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Complete `n"
                $Result[1] | Should -Be "THE FOLLOWING RESOURCES WILL BE OVERWRITTEN! `n Resources exist and mode is complete:"
                $Result[2].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[2].ResourceGroupName | Should -Be "Arm"
            }
            it "When resources would be deleted, they are shown as deleted" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResourcesDeleted.json") | ConvertFrom-Json
                Mock Get-AzureRMResource {
                    [object]$MockAZResource
                }
                $Result = Test-ARMExistingResource @Parameters
                $Result[0] | Should -Be "Mode for deployment is Complete `n"
                $Result[8] | Should -Be "THE FOLLOWING RESOURCES WILL BE DELETED! `n Resources exist in the resourcegroup but not in the template, mode is complete:"
                $Result[9].Type | Should -Be "Microsoft.Storage/storageAccounts"
                $Result[9].ResourceGroupName | Should -Be "Arm"
            }
            it "When ThrowWhenRemoving is used, it will throw if resources are deleted" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResourcesDeleted.json") | ConvertFrom-Json
                Mock Get-AzureRMResource {
                    [object]$MockAZResource
                }
                { Test-ARMExistingResource @Parameters -ThrowWhenRemoving } | Should throw
            }
            it "When ThrowWhenRemoving is used, but  nothing would be overwritten, it will not throw" {
                $MockAZResource = (Get-Content "$PSScriptRoot\MockObjects\ExistingResources.json") | ConvertFrom-Json
                Mock Get-AzureRMResource {
                    [object]$MockAZResource
                }
                { Test-ARMExistingResource @Parameters -ThrowWhenRemoving } | Should throw
            }
            it "Should throw when no result is found" {
                Mock Get-ARMResource { $null }
                { Test-ARMExistingResource @Parameters } | Should throw "Something is wrong with the output, no resources found. Please check your deployment with Get-ARMdeploymentErrorMessage"
            }
            It "Mocks are called" {
                Assert-MockCalled -CommandName Get-ARMResource
                Assert-MockCalled -CommandName Get-AzureRMResource
            }
        }
    }
}
