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

.PARAMETER TemplatePath
The path to the deploymentfile

.PARAMETER ParametersPath
The path to the parameterfile

.EXAMPLE
Test-ARMDeploymentResource -ResourceGroupName Armtest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

.NOTES
Script can be used in a CICD pipeline
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
Source for more output: #Source https://blog.mexia.com.au/testing-arm-templates-with-pester
#>
function Test-ARMDeploymentResource {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string] $ResourceGroupName,
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string] $TemplateFile,
        [Parameter(ParameterSetName='TemplateParameterFile')]
        [string] $TemplateParameterFile,
        [Parameter(ParameterSetName='TemplateParameterObject')]
        [hashtable] $TemplateParameterObject,
        [parameter ()]
        [ValidateSet("Incremental", "Complete")]
        [string] $Mode = "Incremental"
    )
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        Mode                  = $Mode
    }
    if (-not[string]::IsNullOrEmpty($TemplateParameterFile) ){
        $Parameters.Add("TemplateParameterFile",$TemplateParameterFile)
    }
    if (-not[string]::IsNullOrEmpty($TemplateParameterObject) ){
        $Parameters.Add("TemplateParameterObject",$TemplateParameterObject)
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

    #go through each deployed Resource
    foreach ($Resource in $ValidatedResources) {

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

        $ResourceReadable
    }
}


