<#
.SYNOPSIS
Tests an azure deployment for error and outputs the recources that will be deployed

.DESCRIPTION
This function will first test an Arm deployment with Test-AzureRmResourceGroupDeployment.
If a generic error pops up, it will search for details in Azure.
If this test succeeds, an output will be generated that will show what resources will be deployed

.PARAMETER ResourceGroup
The resourcegroup where the resources would be deployed to. If it doesn't exist, it will be created

.PARAMETER TemplatePath
The path to the deploymentfile

.PARAMETER ParametersPath
The path to the parameterfile

.NOTES
This script should be ran within a CI/CD pipeline.
If you want to run it manually, use TestarmPSlocal.ps1
Created by Barbara Forbes, 18-12-2018
Source for more output: #Source https://blog.mexia.com.au/testing-arm-templates-with-pester
#>
function Show-ARMDeployment {
    Param(
        [string] [Parameter(Mandatory = $true)] $ResourceGroupName,
        [string] [Parameter(Mandatory = $true)] $TemplateFile,
        [string] [Parameter(Mandatory = $true)] $TemplateParameterFile

    )

    #give the parameters back to caller
    # Write-Output " Parameters set:"
    # Write-Output $ResourceGroup
    # Write-Output $TemplatePath
    # Write-Output $ParametersPath

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
            "Microsoft.Resources/deployments" {  $PropertiesReadable = Get-PropertiesDeployments $Resource  }
            "Microsoft.Network/networkSecurityGroups" { $PropertiesReadable = Get-PropertiesnetworkSecurityGroups $Resource }
            "Microsoft.Network/virtualNetworks" { $PropertiesReadable = Get-PropertiesVirtualNetworks $Resource }
            "Microsoft.Network/networkInterfaces" { $PropertiesReadable = Get-PropertiesNetworkInterfaces $Resource }
            "Microsoft.Compute/virtualMachines" { $PropertiesReadable = Get-PropertiesVirtualMachines $Resource }
            Default {  $PropertiesReadable = Get-propertiesDefault $Resource }
        }

        foreach ($Property in $PropertiesReadable.keys) {
            $ResourceReadable | Add-Member -MemberType NoteProperty -Name $Property -Value ($PropertiesReadable.$property)

        }

        Write-Output "Resource: $ResourceTypeShort `n"

        $ResourceReadable

    }
}