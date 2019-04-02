---
external help file: ArmHelper-help.xml
Module Name: ARMHelper
online version:
schema: 2.0.0
---

# Get-ARMDeploymentErrorMessage

## SYNOPSIS
Tests an azure deployment for errors, Use the azure Logs if a generic message is given.

## SYNTAX

```
Get-ARMDeploymentErrorMessage [-ResourceGroupName] <String> [-TemplateFile] <String>
 [-TemplateParameterFile] <String> [-Pipeline] [<CommonParameters>]
```

## DESCRIPTION
This function uses Test-AzureRmResourceGroupDeployment.
There is a specific errormessage that's very generic.
If this is the output, the correct errormessage is retrieved from the Azurelog

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
Get-ARMDeploymentErrorMessage Armtesting .\VM01\azuredeploy.json .\VM01\azuredeploy.parameters.json
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
The path to the deploymentfile

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
The path to the parameterfile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pipeline
Use this parameter if this script is used in a CICDpipeline.
It will make the step fail.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes

## RELATED LINKS
