---
external help file: ARMHelper-help.xml
Module Name: ARMHelper
online version:
schema: 2.0.0
---

# Test-ARMExistingResource

## SYNOPSIS
Show if resource that are set to be deployed already exist

## SYNTAX

### __AllParameterSets (Default)
```
Test-ARMExistingResource [-ResourceGroupName] <String> [-TemplateFile] <String> [-Mode <String>]
 [-ThrowWhenRemoving] [<CommonParameters>]
```

### TemplateParameterFile
```
Test-ARMExistingResource [-ResourceGroupName] <String> [-TemplateFile] <String> -TemplateParameterFile <String>
 [-Mode <String>] [-ThrowWhenRemoving] [<CommonParameters>]
```

### TemplateParameterObject
```
Test-ARMExistingResource [-ResourceGroupName] <String> [-TemplateFile] <String>
 -TemplateParameterObject <Hashtable> [-Mode <String>] [-ThrowWhenRemoving] [<CommonParameters>]
```

## DESCRIPTION
This function uses Test-AzureRmResourceGroupDeployment or Test-AzResourceGroupDeployment with debug output to find out what resources are deployed.
After that, it checks if those resources exist in Azure.
It will output the results when using complete mode or incremental mode (depending on the ARM template)

## EXAMPLES

### EXAMPLE 1
```
Test-ARMexistingResource -ResourceGroupName ArmTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json
```

--------
The following resources exist. Mode is set to incremental. New properties might be added:

type                                               name                                               Current ResourcegroupName
----                                               ----                                               -------------------------
Microsoft.Storage/storageAccounts                  armsta                                             armtest

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
Parameter Sets: TemplateParameterFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateParameterObject
{{ Fill TemplateParameterObject Description }}

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
The mode in which the deployment will run.
Choose between Incremental or Complete.
Defaults to incremental.

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

### -ThrowWhenRemoving
This switch makes the function throw when a resources would be overwritten or deleted.
This can be useful for use in a pipeline.

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
