# ARMHelper

[![Build Status](https://dev.azure.com/Ba4bes/ARMHelper/_apis/build/status/Ba4bes.ARMHelper?branchName=master)](https://dev.azure.com/Ba4bes/ARMHelper/_build/latest?definitionId=8&branchName=master)
[![Build Status](https://vsrm.dev.azure.com/Ba4bes/_apis/public/Release/badge/fe28574d-f965-479f-bc02-25d7534d9aeb/1/1)](https://vsrm.dev.azure.com/Ba4bes/_apis/public/Release/badge/fe28574d-f965-479f-bc02-25d7534d9aeb/1/1)

[![Gallery version](https://img.shields.io/powershellgallery/v/ARMHelper.svg)](https://img.shields.io/powershellgallery/v/ARMHelper.svg)
[![Download Status](https://img.shields.io/powershellgallery/dt/ARMHelper.svg)](https://img.shields.io/powershellgallery/dt/ARMHelper.svg) 

This module is created to make it easier to work with ARM deployments.

You are at this point able to:

- Get detailed errormessages when Azure gives general errors
- Get an overview of all the resources that would get deployed
- Check if resources that you want to deploy already exist and whether they would be overwritten.

For an introduction, please view  <http://4bes.nl/2019/04/09/armhelper-a-module-to-help-create-arm-templates> 

## Common setup

### prerequisites

- Access to an Azure subscription
- Have the AzureRM module installed and a connection ready
- Windows Powershell. At this point, Core is not yes supported.

### Installation

Install ARMHelper from the [PowerShell Gallery](https://powershellgallery.com):

```powershell
Install-Module -Name ARMHelper -Scope CurrentUser
Import-Module ARMHelper
```

## Examples

### Get a detailed output for a general error

```cmd
C:\> Get-ARMDeploymentErrorMessage -ResourceGroupName ARMTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

the output is a generic error message. The log is searched for a more clear errormessage
General Error. Find info below:
ErrorCode: AccountNameInvalid
Errormessage: arm-aqkc32cvb2qmmw is not a valid storage account name. Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
```

### Get an overview of the new resources that would be deployed

```cmd
C:\> Test-ARMDeploymentResource -ResourceGroupName ARMTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

Mode for deployment is Incremental
The following Resources will be deployed:


 Resource: storageAccounts

Name        : armaqkc32cvb2qmmw
Type        : Microsoft.Storage/storageAccounts
ID          : /subscriptions/61115fe7-d5b1-4f92-a54a-69c4b7a2a1c8/resourceGroups/armtesting/providers/Microsoft.Storage/storageAccounts/armaqkc32cvb2qmmw
Location    : westeurope
accountType : Standard_LRS
apiVersion  : 2015-06-15
ARMcreated  : True
displayName : armaqkc32cvb2qmmw
```

### Test if a Resource exists already

```cmd
C:\> Test-ARMExistingResource -ResourceGroupName armtesting -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

Mode for deployment is Incremental
The following resources do not exist and will be created
armaqkc32cvb2qmmw

C:\> Test-ARMExistingResource -ResourceGroupName armtesting -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

Mode for deployment is Incremental
The following resources exist. Mode is set to incremental. New properties might be added
armaqkc32cvb2qmmw

```

See Docs-folder for more documentation. (Generated with PlatyPS )

## Change Log

View Change log [here](CHANGELOG.md)

## To Contribute

Any ideas or contributions are welcome!
Please add an issue with your suggestions.

## Known Issues

View known issues [here](https://github.com/Ba4bes/ARMHelper/issues)
