<#
.SYNOPSIS
Show if resource that are set to be deployed already exist

.DESCRIPTION
This function uses Test-AzureRMResourceGroupDeployment with debug output to find out what resources are deployed.
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
Get-ARMDeployErrorMessage -ResourceGroupName ArmTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

--------
the output is a generic error message. The log is searched for a more clear errormessageGeneral Error. Find info below:
ErrorCode: InvalidDomainNameLabel
Errormessage: The domain name label LABexample is invalid. It must conform to the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.

.EXAMPLE
Get-ARMDeployErrorMessage Armtesting .VM01\azuredeploy.json .VM01\azuredeploy.parameters.json

--------
deployment is correct

.NOTES
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
#>
Function Test-ARMExistingResource {
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
    #make sure the debugpreference is right, as otherwise the simpletest will give confusing results
    $DebugPreference = "SilentlyContinue"

    #set variables
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
        Mode                  = $Mode
    }
    #Write-Output "Test is starting"


    $Output = $null
    #set debugpreference to continue so the Test-AzureRmResourceGroupDeployment runs with more output
    $DebugPreference = "Continue"

    $Output = Test-AzureRmResourceGroupDeployment @parameters 5>&1 -ErrorAction Stop

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
        $Check = Get-AzureRmResource -Name $Resource.name -ResourceType $resource.type
        if ([string]::IsNullOrEmpty($check)){
            Write-output "Resource $($Resource.name) does not exist, it will be created"
        }
        else {
            if ($Result.Mode -eq "Complete"){
                Write-Output "Resource $($Resource.name) already exists and mode is set to Complete"
                Write-output "RESOURCE WILL BE OVERWRITTEN!"
            }
            elseif ($Result.Mode -eq "Incremental"){
                Write-Output "Resource $($Resource.name) already exists, mode is set to incremental"
                Write-output "New properties might be added"
            }
            else {
                Write-Output "Resource mode is not clear"
            }
        }
    }
}