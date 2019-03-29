<#
.SYNOPSIS
Gives output that shows all resources that would be deployed by an ARMtemplate

.DESCRIPTION
When you enter a ARM template and a parameter file, this function will show what would be deployed
To do this, it used the debug output of Test-AzureRMResourceGroupDeployment.
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
Show-ARMDeployment -ResourceGroupName Armtest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json


.NOTES
Script can be used in a CICD pipeline
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
Source for more output: #Source https://blog.mexia.com.au/testing-arm-templates-with-pester
#>
function Show-ARMDeployment {
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

    #make sure the debugpreference is right, as otherwise the simpletest will give confusing results
    $DebugPreference = "SilentlyContinue"

    #set variables
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
    }
    #Write-Output "Test is starting"


    $Output = $null
    #set debugpreference to continue so the Test-AzureRmResourceGroupDeployment runs with more output
    $DebugPreference = "Continue"

    $Output = Test-AzureRmResourceGroupDeployment @parameters 5>&1

    #Set DebugPreference back to normal
    $DebugPreference = "SilentlyContinue"

    #Write-Output "collected Output"

    #Grap the specific part of the output that tells you about the deployed Resources
    $Response = $Output | where-object {$_.Message -like "*http response*"}
    #get the jsonpart en convert it to work with it.
    $Result = (($Response -split "Body:")[1] | ConvertFrom-Json).Properties

    #tell the user if de mode is complete or incremental
    Write-Output "Mode for deployment is $($Result.Mode)"

    $ValidatedResources = $Result.ValidatedResources
    Write-Output "The following Resources will be deployed: `n"

    #go through each deployed Resource
    foreach ($Resource in $ValidatedResources) {

        $ResourceTypeShort = $($Resource.type.Split("/")[-1])
        #Write-Output "Creating Resource: $($Resource.type.Split("/")[-1])"

        $ResourceReadable = [PSCustomObject] @{
            Name     = $Resource.name
            Type     = $Resource.type
            ID       = $Resource.id
            Location = $Resource.location

        }
        #$ResourceReadable = New-Object -TypeName psobject @hash
        $PropertiesReadable = @{}
        switch ($Resource.type) {
            "Microsoft.Resources/deployments" {  $PropertiesReadable = Get-PropertiesDeployment $Resource  }
            "Microsoft.Network/networkSecurityGroups" { $PropertiesReadable = Get-PropertiesnetworkSecurityGroup $Resource }
            "Microsoft.Network/virtualNetworks" { $PropertiesReadable = Get-PropertiesVirtualNetwork $Resource }
            "Microsoft.Network/networkInterfaces" { $PropertiesReadable = Get-PropertiesNetworkInterface $Resource }
            "Microsoft.Compute/virtualMachines" { $PropertiesReadable = Get-PropertiesVirtualMachine $Resource }
            Default {  $PropertiesReadable = Get-propertiesDefault $Resource }
        }

        foreach ($Property in $PropertiesReadable.keys) {
            $ResourceReadable | Add-Member -MemberType NoteProperty -Name $Property -Value ($PropertiesReadable.$property) -ErrorAction SilentlyContinue

        }

        Write-Output "Resource: $ResourceTypeShort `n"

        $ResourceReadable | Format-List

    }
}