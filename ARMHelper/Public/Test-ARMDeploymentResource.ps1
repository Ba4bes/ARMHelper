<#
.SYNOPSIS
Gives output that shows all resources that would be deployed by an ARMtemplate

.DESCRIPTION
When you enter a ARM template and a parameter file, this function will show what would be deployed
To do this, it used the debug output of Test-AzureRmResourceGroupDeployment.
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
        [Parameter(Position = 3, Mandatory = $true)]
        [string] $TemplateParameterFile
    )
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
    }
    $Result = Get-ARMResource @Parameters
    if ([string]::IsNullOrEmpty($Result.Mode)) {
        Throw "Something is wrong with the output, no resources found. Please check your deployment with Get-ARMdeploymentErrorMessage"
    }
    
    <#
        Ik vroeg me bij alledrie de functies af: heeft het zin om de ouput in object-vorm te doen? Ik weet wel dat 
        dat in CI weinig zin heeft, maar in alle andere gevallen zou dat wel mooier werken, mocht je er logica omheen willen bouwen.
        Ik heb nu even geen voorbeeld van hoe dat er dan uit zou moeten zien, maar vind het iets om over na te denken.
    #>
    
    #tell the user if de mode is complete or incremental
    Write-Output "Mode for deployment is $($Result.Mode)"

    $ValidatedResources = $Result.ValidatedResources
    Write-Output "The following Resources will be deployed: `n"

    #go through each deployed Resource
    foreach ($Resource in $ValidatedResources) {

        $ResourceTypeShort = $($Resource.type.Split("/")[-1])

        $ResourceReadable = [PSCustomObject] @{
            Name     = $Resource.name
            Type     = $Resource.type
            ID       = $Resource.id
            Location = $Resource.location
        }
        $PropertiesReadable = Get-ResourceProperty -Object $Resource

        foreach ($Property in $PropertiesReadable.keys) {
            $ResourceReadable | Add-Member -MemberType NoteProperty -Name $Property -Value ($PropertiesReadable.$Property) -ErrorAction SilentlyContinue
    }

    Write-Output "`n Resource: $ResourceTypeShort "
    $ResourceReadable
}
}
