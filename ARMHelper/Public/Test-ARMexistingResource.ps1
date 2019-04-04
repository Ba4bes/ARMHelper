<#
.SYNOPSIS
Show if resource that are set to be deployed already exist

.DESCRIPTION
This function uses Test-AzureRmResourceGroupDeployment with debug output to find out what resources are deployed.
After that, it checks if those resources exist in Azure.
It will output the results when using complete mode or incremental mode (depending on the ARM template)

.PARAMETER ResourceGroupName
The resourcegroup where the resources would be deployed to. This resourcegroup needs to exist.

.PARAMETER TemplateFile
The path to the deploymentfile

.PARAMETER TemplateParameterFile
The path to the parameterfile

.PARAMETER Mode
The mode in which the deployment will run. Choose between Incremental or Complete.
Defaults to incremental.

.EXAMPLE
Get-ARMDeploymentErrorMessage -ResourceGroupName ArmTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

--------
the output is a generic error message. The log is searched for a more clear errormessageGeneral Error. Find info below:
ErrorCode: InvalidDomainNameLabel
Errormessage: The domain name label LABexample is invalid. It must conform to the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.

.EXAMPLE
Get-ARMexistingResource Armtesting .\VM01\azuredeploy.json .\VM01\azuredeploy.parameters.json

--------
deployment is correct

.NOTES
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
#>
Function Test-ARMExistingResource {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string] $ResourceGroupName,
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string] $TemplateFile,
        [Parameter(Position = 3, Mandatory = $true)]
        [string] $TemplateParameterFile,
        [parameter ()]
        [ValidateSet("Incremental", "Complete")]
        [string] $Mode = "Incremental"
    )

    #set variables
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
        Mode                  = $Mode
    }

    $Result = Get-ARMResource @Parameters

    #tell the user if de mode is complete or incremental
    Write-Output "Mode for deployment is $($Result.Mode)"

    $ValidatedResources = $Result.ValidatedResources
    $NewResources = [System.Collections.ArrayList]@()
    $ExistingResources = [System.Collections.ArrayList]@()
    $OverwrittenResources = [System.Collections.ArrayList]@()
    $DifferentResourcegroup = @{}

    #go through each deployed Resource
    foreach ($Resource in $ValidatedResources) {
        $Check = Get-AzureRmResource -Name $Resource.name -ResourceType $Resource.type
        if ([string]::IsNullOrEmpty($Check)) {
            Write-Verbose "Resource $($Resource.name) does not exist, it will be created"
            $null = $NewResources.Add($Resource.Name)
        }
        else {
            if ($Check.ResourceGroupName -eq $ResourceGroupName ){
            if ($Result.Mode -eq "Complete") {
                Write-Verbose "Resource $($Resource.name) already exists and mode is set to Complete"
                Write-Verbose "RESOURCE WILL BE OVERWRITTEN!"
                $null = $OverwrittenResources.Add($Resource.Name)
            }
            elseif ($Result.Mode -eq "Incremental") {
                Write-Verbose "Resource $($Resource.name) already exists, mode is set to incremental"
                Write-Verbose "New properties might be added"
                $null = $ExistingResources.Add($Resource.Name)
            }
            else {
                Write-Error "Resource mode for $($Resource.name) is not clear, please check manually"
            }
        }
        else{
            Write-Verbose "$($Resource.name) exists, but in another ResourceGroup. Deployment might fail."
            $DifferentResourcegroup.Add($Resource.Name, $Check.ResourceGroupName)
        }
        }
    }
    if (-not [string]::IsNullOrEmpty($NewResources)) {
        Write-Output "The following resources do not exist and will be created"
        $NewResources
        Write-Output ""
    }

    if (-not [string]::IsNullOrEmpty($ExistingResources)) {
        Write-Output "The following resources exist. Mode is set to incremental. New properties might be added"
        $ExistingResources
        Write-Output ""
    }

    if (-not [string]::IsNullOrEmpty($OverwrittenResources)) {
        Write-Output "THE FOLLOWING RESOURCES WILL BE OVERWRITTEN! `n Resources exist and mode is complete."
        $OverwrittenResources
        Write-Output ""
    }
    if (-not [string]::IsNullOrEmpty($DifferentResourcegroup)) {
        Write-Output "The following resources exists, but in a different ResourceGroup. This deployment might fail."
        Write-Output "Resourcegroup for this deployment: $ResourceGroup"
        $DifferentResourcegroup | Select-object @{l='Resource';e={$_.keys}},@{l='ResourceGroup';e={$_.values}}
        Write-Output ""
    }
}
