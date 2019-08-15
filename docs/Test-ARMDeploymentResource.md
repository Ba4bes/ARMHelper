---
external help file: ARMHelper-help.xml
Module Name: ARMHelper
online version:
schema: 2.0.0
---

# Test-ARMDeploymentResource

## SYNOPSIS
Gives output that shows all resources that would be deployed by an ARMtemplate

## SYNTAX

### __AllParameterSets (Default)
```
Test-ARMDeploymentResource [-ResourceGroupName] <String> [-TemplateFile] <String> [-Mode <String>]
 [<CommonParameters>]
```

### TemplateParameterFile
```
Test-ARMDeploymentResource [-ResourceGroupName] <String> [-TemplateFile] <String>
 -TemplateParameterFile <String> [-Mode <String>] [<CommonParameters>]
```

### TemplateParameterObject
```
Test-ARMDeploymentResource [-ResourceGroupName] <String> [-TemplateFile] <String>
 -TemplateParameterObject <Hashtable> [-Mode <String>] [<CommonParameters>]
```

## DESCRIPTION
When you enter a ARM template and a parameter file, this function will show what would be deployed
To do this, it used the debug output of Test-AzureRmResourceGroupDeployment or Test-AzResourceGroupDeployment.
A list of all the resources is provided with the most important properties.
Some resources have seperated functions to structure the output.
If no function is available, a generic output will be given.

## EXAMPLES

### EXAMPLE 1
```
Test-ARMDeploymentResource -ResourceGroupName Armtest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```

--------
Resource : storageAccounts
Name     : armsta12356
Type     : Microsoft.Storage/storageAccounts
Location : westeurope
mode     : Incremental
ID       : /subscriptions/12345678-abcd-1234-1234-12345678/resourceGroups/arm/providers/Microsoft.Storage/storageAccounts/armsta12356

### EXAMPLE 2
```
Test-ARMDeploymentResource armtesting .\azuredeploy.json -TemplateParameterObject $parameters | select *
```

--------
Resource          : storageAccounts
Name              : armsta12356
Type              : Microsoft.Storage/storageAccounts
ID                : /subscriptions/12345678-abcd-1234-1234-12345678/resourceGroups/armtesting/providers/Microsoft.Storage/storageAccounts/armsta12356
Location          : westeurope
Tags: ARMcreated  : True
accountType       : Standard_LRS
apiVersion        : 2015-06-15
Tags: displayName : armsta12356
mode              : Incremental

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

### -Mode
{{ Fill Mode Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Incremental
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

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
