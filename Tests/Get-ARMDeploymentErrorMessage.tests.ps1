$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Import-Module (Join-Path $moduleRoot "$moduleName.psd1") -force



Describe 'Check Get-ARMDEploymentErrorMessage' -Tag @("Mock") {
    InModuleScope ARMHelper {
        $Parameters = @{
            resourcegroupname     = "Arm"
            templatefile          = "$PSScriptRoot\MockObjects\azuredeploy.json"
            templateparameterfile = ".\azuredeploy.parameters.json"
        }
        Context 'Basic functionality AzureRM' {
            function Test-AzureRMResourceGroupDeployment([String]$Name, [Object]$Value, [Switch]$Clobber) { }

            function Get-AzureRMLog([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            Mock Test-ARMAzureModule { "AzureRM" }
            It "Works with a parameterFile" {
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
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
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "works with added Parameters" {
                $Parameters = @{
                    resourcegroupname    = "Arm"
                    templatefile         = "$PSScriptRoot\MockObjects\azuredeploy.json"
                    storageAccountPrefix = "armsta"
                    storageAccountType   = "LRS"
                }
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "When a deployment is correct, output is deployment is correct" {
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "When deployment has a regular error, it is given" {
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "Deployment template validation failed"
                    }
                }
                $Test = Get-ARMDeploymentErrorMessage @Parameters
                $Test[0] | Should -Be "Error, Find info below:"
                $Test[1] | Should -Be "Deployment template validation failed"
            }
            It "When deployment has a general error, the right results are given" {
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "The template deployment '12345678-1234-1234-1234-12345678abcd' is not valid according to the validation procedure. The
                tracking id is '12345678-1234-1234-1234-12345678abcd'. See inner errors for details. Please see https://aka.ms/arm-deploy
                for usage details."
                    }
                }
                $Mockobject = (Get-Content $PSScriptRoot\MockObjects\Logoutput.json) | ConvertFrom-Json
                Mock Get-AzureRMLog {
                    [object]$Mockobject
                }
                Mock Start-Sleep { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result[0] | Should -Be "the output is a generic error message. The log is searched for a more clear errormessage"
                $Result[-3] | Should -Be "General Error. Find info below:"
                $Result[-2] | Should -Be "ErrorCode: AccountNameInvalid"
                $Result[-1] | Should -Be "Errormessage: s aqkc32cvb2qmmw is not a valid storage account name. Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only."
            }
            It "When no errormessage is found in azurelog, script throws" {
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "The template deployment '12345678-1234-1234-1234-12345678abcd' is not valid according to the validation procedure. The
                    tracking id is '12345678-1234-1234-1234-12345678abcd'. See inner errors for details. Please see https://aka.ms/arm-deploy
                    for usage details."
                    }
                }
                Mock Get-AzureRMLog {
                    $null
                }
                Mock Start-Sleep { $null }
                { Get-ARMDeploymentErrorMessage @Parameters } | Should -Throw "Can't get Azure Log Entry. Please check the log manually in the portal."
            }
            It "Throws when TrowonError is used" {
                Mock Test-AzureRmResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "The template deployment '12345678-1234-1234-1234-12345678abcd' is not valid according to the validation procedure. The
                    tracking id is '12345678-1234-1234-1234-12345678abcd'. See inner errors for details. Please see https://aka.ms/arm-deploy
                    for usage details."
                    }
                }
                $Mockobject = (Get-Content $PSScriptRoot\MockObjects\Logoutput.json) | ConvertFrom-Json
                Mock Get-AzureRMLog {
                    [object]$Mockobject
                }
                Mock Start-Sleep { $null }
                { Get-ARMDeploymentErrorMessage @Parameters -ThrowOnError } | Should -Throw  "Deployment is incorrect"

            }
            It "All Mocks are called" {
                Assert-MockCalled -CommandName Get-AzureRmLog
                Assert-MockCalled -CommandName Test-AzureRmResourceGroupDeployment
            }
        }
        Context 'Basic functionality Az' {
            function Test-AzResourceGroupDeployment([String]$Name, [Object]$Value, [Switch]$Clobber) { }
            function Get-AzLog([String]$Name, [Object]$Value, [Switch]$Clobber) { }

            Mock Test-ARMAzureModule { "Az" }
            It "Works with a parameterFile" {
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
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
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "works with added Parameters" {
                $Parameters = @{
                    resourcegroupname    = "Arm"
                    templatefile         = "$PSScriptRoot\MockObjects\azuredeploy.json"
                    storageAccountPrefix = "armsta"
                    storageAccountType   = "LRS"
                }
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "When a deployment is correct, output is deployment is correct" {
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result | Should -Be "deployment is correct"
            }
            It "When deployment has a regular error, it is given" {
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "Deployment template validation failed"
                    }
                }
                $Test = Get-ARMDeploymentErrorMessage @Parameters
                $Test[0] | Should -Be "Error, Find info below:"
                $Test[1] | Should -Be "Deployment template validation failed"
            }
            It "When deployment has a general error, the right results are given" {
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "The template deployment '12345678-1234-1234-1234-12345678abcd' is not valid according to the validation procedure. The
                tracking id is '12345678-1234-1234-1234-12345678abcd'. See inner errors for details. Please see https://aka.ms/arm-deploy
                for usage details."
                    }
                }
                $Mockobject = (Get-Content $PSScriptRoot\MockObjects\Logoutput.json) | ConvertFrom-Json
                Mock Get-AzLog {
                    [object]$Mockobject
                }
                Mock Start-Sleep { $null }
                $Result = Get-ARMDeploymentErrorMessage @Parameters
                $Result[0] | Should -Be "the output is a generic error message. The log is searched for a more clear errormessage"
                $Result[-3] | Should -Be "General Error. Find info below:"
                $Result[-2] | Should -Be "ErrorCode: AccountNameInvalid"
                $Result[-1] | Should -Be "Errormessage: s aqkc32cvb2qmmw is not a valid storage account name. Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only."
            }
            It "When no errormessage is found in azurelog, script throws" {
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "The template deployment '12345678-1234-1234-1234-12345678abcd' is not valid according to the validation procedure. The
                    tracking id is '12345678-1234-1234-1234-12345678abcd'. See inner errors for details. Please see https://aka.ms/arm-deploy
                    for usage details."
                    }
                }
                Mock Get-AzLog {
                    $null
                }
                Mock Start-Sleep { $null }
                { Get-ARMDeploymentErrorMessage @Parameters } | Should -Throw "Can't get Azure Log Entry. Please check the log manually in the portal."
            }
            It "Throws when TrowonError is used" {
                Mock Test-AzResourceGroupDeployment -parameterfilter { $Parameters } {
                    [pscustomobject]@{
                        Code    = 'InvalidTemplateDeployment'
                        Message = "The template deployment '12345678-1234-1234-1234-12345678abcd' is not valid according to the validation procedure. The
                    tracking id is '12345678-1234-1234-1234-12345678abcd'. See inner errors for details. Please see https://aka.ms/arm-deploy
                    for usage details."
                    }
                }
                $Mockobject = (Get-Content $PSScriptRoot\MockObjects\Logoutput.json) | ConvertFrom-Json
                Mock Get-AzLog {
                    [object]$Mockobject
                }
                Mock Start-Sleep { $null }
                { Get-ARMDeploymentErrorMessage @Parameters -ThrowOnError } | Should -Throw  "Deployment is incorrect"

            }
            It "All Mocks are called" {
                Assert-MockCalled -CommandName Get-AzLog
                Assert-MockCalled -CommandName Test-AzResourceGroupDeployment
            }
        }
    }
}
