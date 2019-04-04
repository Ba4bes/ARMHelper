---
external help file: ArmHelper-help.xml
Module Name: ARMHelper
online version:
schema: 2.0.0
---

# Test-ARMDeploymentResource

## SYNOPSIS
Gives output that shows all resources that would be deployed by an ARMtemplate

## SYNTAX

```
Test-ARMDeploymentResource [-ResourceGroupName] <String> [-TemplateFile] <String> [-TemplateParameterFile] <String>
 [<CommonParameters>]
```

## DESCRIPTION
When you enter a ARM template and a parameter file, this function will show what would be deployed
To do this, it used the debug output of Test-AzureRmResourceGroupDeployment.
A list of all the resources is provided with the most important properties.
Some resources have seperated functions to structure the output.
If no function is available, a generic output will be given.

## EXAMPLES

### EXAMPLE 1
```
Test-ARMDeploymentResource -ResourceGroupName Armtest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```

## PARAMETERS

### -ResourceGroupName
{{ Fill ResourceGroupName Description }}

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
{{ Fill TemplateFile Description }}

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
{{ Fill TemplateParameterFile Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Script can be used in a CICD pipeline
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
Source for more output: #Source https://blog.mexia.com.au/testing-arm-templates-with-pester

## RELATED LINKS
