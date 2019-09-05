---
external help file: ARMHelper-help.xml
Module Name: ARMHelper
online version:
schema: 2.0.0
---

# Get-ARMDeploymentErrorMessage

## SYNOPSIS
Tests an azure deployment for errors, Use the azure Logs if a generic message is given.

## SYNTAX

### __AllParameterSets (Default)
```
Get-ARMDeploymentErrorMessage [-ResourceGroupName] <String> [-TemplateFile] <String> [-Pipeline]
 [-ThrowOnError] [<CommonParameters>]
```

### TemplateParameterFile
```
Get-ARMDeploymentErrorMessage [-ResourceGroupName] <String> [-TemplateFile] <String>
 -TemplateParameterFile <String> [-Pipeline] [-ThrowOnError] [<CommonParameters>]
```

### TemplateParameterObject
```
Get-ARMDeploymentErrorMessage [-ResourceGroupName] <String> [-TemplateFile] <String>
 -TemplateParameterObject <Hashtable> [-Pipeline] [-ThrowOnError] [<CommonParameters>]
```

## DESCRIPTION
This function uses Test-AzureRmResourceGroupDeployment or Test-AZResourcegroupDeployment.
There is a specific errormessage that's very generic.
If this is the output, the correct errormessage is retrieved from the Azurelog.

## EXAMPLES

### EXAMPLE 1
```
Get-ARMDeploymentErrorMessage -ResourceGroupName ArmTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```

--------
the output is a generic error message. The log is searched for a more clear errormessageGeneral Error. Find info below:
ErrorCode: InvalidDomainNameLabel
Errormessage: The domain name label LABexample is invalid. It must conform to the following regular expression: ^\[a-z\]\[a-z0-9-\]{1,61}\[a-z0-9\]$.

### EXAMPLE 2
```
Get-ARMDeploymentErrorMessage Armtesting .\VM01\azuredeploy.json -TemplateParameterObject $Parameters
```

--------
deployment is correct

## PARAMETERS

### -ResourceGroupName
The resourcegroup where the resources would be deployed to.
This resourcegroup needs to exist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateFile
The path to the templatefile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateParameterFile
The path to the parameterfile, optional

```yaml
Type: String
Parameter Sets: TemplateParameterFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateParameterObject
A Hasbtable with parameters, optional

```yaml
Type: Hashtable
Parameter Sets: TemplateParameterObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pipeline
Use this parameter if this script is used in a CICDpipeline.
It will make the step fail.
This parameter is replaced by ThrowOnError and will be removed in a later release!

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrowOnError
This Switch will make the cmdlet throw when the deployment is incorrect.
This can be useful in a pipeline, it will make the task fail.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Dynamic Parameters like in the orginal Test-AzResourcegroupDeployment-cmdlet are supported
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes

## RELATED LINKS
