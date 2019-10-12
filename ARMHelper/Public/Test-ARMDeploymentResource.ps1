<#
.SYNOPSIS
Gives output that shows all resources that would be deployed by an ARMtemplate

.DESCRIPTION
When you enter a ARM template and a parameter file, this function will show what would be deployed
To do this, it used the debug output of Test-AzureRmResourceGroupDeployment or Test-AzResourceGroupDeployment.
A list of all the resources is provided with the most important properties.
Some resources have seperated functions to structure the output.
If no function is available, a generic output will be given.

.PARAMETER ResourceGroup
The resourcegroup where the resources would be deployed to. If it doesn't exist, it will be created

.PARAMETER TemplateFile
The path to the templatefile

.PARAMETER TemplateParameterFile
The path to the parameterfile, optional

.PARAMETER TemplateParameterObject
A Hasbtable with parameters, optional

.EXAMPLE
Test-ARMDeploymentResource -ResourceGroupName Armtest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

--------
Resource : storageAccounts
Name     : armsta12356
Type     : Microsoft.Storage/storageAccounts
Location : westeurope
mode     : Incremental
ID       : /subscriptions/12345678-abcd-1234-1234-12345678/resourceGroups/arm/providers/Microsoft.Storage/storageAccounts/armsta12356

.EXAMPLE
Test-ARMDeploymentResource armtesting .\azuredeploy.json -TemplateParameterObject $parameters | select *

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

.NOTES
Dynamic Parameters like in the orginal Test-AzResourcegroupDeployment-cmdlet are supported
Script can be used in a CICD pipeline
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
Source for more output: #Source https://blog.mexia.com.au/testing-arm-templates-with-pester
#>
function Test-ARMDeploymentResource {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    Param(
        [Parameter(
            Position = 1,
            Mandatory = $true,
            ParameterSetName = "__AllParameterSets"
        )]
        [ValidateNotNullorEmpty()]
        [string] $ResourceGroupName,

        [Parameter(
            Position = 2,
            Mandatory = $true,
            ParameterSetName = "__AllParameterSets"
        )]
        [ValidateNotNullorEmpty()]
        [string] $TemplateFile,

        [Parameter(
            ParameterSetName = 'TemplateParameterFile',
            Mandatory = $true
        )]
        [string] $TemplateParameterFile,

        [Parameter(
            ParameterSetName = 'TemplateParameterObject',
            Mandatory = $true
        )]
        [hashtable] $TemplateParameterObject,

        [parameter (
            ParameterSetName = "__AllParameterSets",
            Mandatory = $false
        )]
        [ValidateSet("Incremental", "Complete")]
        [string] $Mode = "Incremental"
    )
    DynamicParam {
        if ($TemplateFile) {
            #create a new ParameterAttribute Object
            $OverRideParameter = New-Object System.Management.Automation.ParameterAttribute
            $OverRideParameter.Mandatory = $false
            #create an attributecollection object for the attribute we just created.
            $AttributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($OverRideParameter)
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $Parameters = (Get-Content $TemplateFile | ConvertFrom-Json).parameters
            $ParameterValues = $parameters | Get-Member -MemberType NoteProperty
            ForEach ($Param in $ParameterValues) {
                $Name = $Param.Name
                $type = ($Parameters.$Name).type
                #add our paramater specifying the attribute collection
                $ExtraParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Param.Name, ($Type -as [type]), $attributeCollection)

                #expose the name of our parameter

                $paramDictionary.Add($Param.Name, $ExtraParam)
            }
            return $paramDictionary
        }
    }
    process {

        $Parameters = @{
            ResourceGroupName = $ResourceGroupName
            TemplateFile      = $TemplateFile
            Mode              = $Mode
        }
        if (-not[string]::IsNullOrEmpty($TemplateParameterFile) ) {
            $Parameters.Add("TemplateParameterFile", $TemplateParameterFile)
        }
        if (-not[string]::IsNullOrEmpty($TemplateParameterObject) ) {
            $Parameters.Add("TemplateParameterObject", $TemplateParameterObject)
        }
        $CustomParameters = (Get-Content $TemplateFile | ConvertFrom-Json).parameters
        $CustomParameterValues = $Customparameters | Get-Member -MemberType NoteProperty
        foreach ($param in $CustomParameterValues) {
            $paramname = $param.Name
            if (-not[string]::IsNullOrEmpty($PSBoundParameters.$paramname)) {
                $Key = $paramname
                $Value = $PSBoundParameters.$paramname
                $Parameters.Add($Key, $Value)
            }
        }

        $Result = Get-ARMResource @Parameters
        if ([string]::IsNullOrEmpty($Result.Mode)) {
            Throw "Something is wrong with the output, no resources found. Please check your deployment with Get-ARMdeploymentErrorMessage"
        }

        # A list of securestrings is created to mask the output at a later time
        $Resultparameters = ($Result.parameters) | get-member -MemberType NoteProperty
        $SecureParameters = [System.Collections.Generic.List[string]]::new()

        Foreach ($parameter in $Resultparameters) {
            $Type = $result.parameters.$($parameter.Name).Type
            If ($Type -eq "SecureString") {
                $SecureParameters.Add($Parameter.Name)
            }
        }

        $ValidatedResources = $Result.ValidatedResources
        # Check the module version used, as AZ has limited output
        $Module = Test-ARMAzureModule
        if ($Module -eq "Az"){
        Write-Warning "The AZ-module is used. This limits the results of this cmdlet. `n
        To get full results, consider temporary switching to the AzureRM-module"
        }

        #go through each deployed Resource
        foreach ($Resource in $ValidatedResources) {
            if ([string]::IsNullOrEmpty($Resource.Type) ) {
                $Resourceparts = $Resource.Id.Split('/')
                $ResourceName = $Resourceparts[-1]
                $ResourceType = $Resourceparts[-3] + "/" + $Resourceparts[-2]
                $ResourceTypeshort = $Resourceparts[-2]
                $ResourceReadable = [PSCustomObject]@{
                    Resource = $ResourceTypeShort
                    Name     = $ResourceName
                    Type     = $Resourcetype
                    ID       = $Resource.id
                }
            }
            else {

                $ResourceTypeShort = $($Resource.type.Split("/")[-1])

                $ResourceReadable = [PSCustomObject] @{
                    Resource = $ResourceTypeShort
                    Name     = $Resource.name
                    Type     = $Resource.type
                    ID       = $Resource.id
                    Location = $Resource.location
                }
                $PropertiesReadable = Get-ResourceProperty -Object $Resource

                foreach ($Property in $PropertiesReadable.keys) {
                    $ResourceReadable | Add-Member -MemberType NoteProperty -Name $Property -Value ($PropertiesReadable.$Property) -ErrorAction SilentlyContinue
                }
                #Add mode when it is not defined
                if ([string]::IsNullOrEmpty($ResourceReadable.mode)) {
                    $ResourceReadable | Add-Member -MemberType NoteProperty -Name "mode" -Value ($Result.mode) -ErrorAction SilentlyContinue
                }
                $ResourceReadable.PSObject.TypeNames.Insert(0, 'ARMHelper.Default')
            }
            $ResourceReadable
        }
    }
}


