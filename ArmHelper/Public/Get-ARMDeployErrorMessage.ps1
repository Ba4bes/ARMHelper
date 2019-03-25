<#
.SYNOPSIS
Tests an azure deployment for errors, Use the azure Logs if a generic message is given.

.DESCRIPTION
This function uses Test-AzureRMResourceGroupDeployment. There is a specific errormessage that's very generic.
If this is the output, the correct errormessage is retrieved from the Azurelog

.PARAMETER ResourceGroupName
The resourcegroup where the resources would be deployed to. This resourcegroup needs to exist.

.PARAMETER TemplateFile
The path to the deploymentfile

.PARAMETER TemplateParameterFile
The path to the parameterfile

.PARAMETER Pipeline
Use this parameter if this script is used in a CICDpipeline. It will make the step fail.

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
function Get-ARMDeployErrorMessage {
    Param(
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string] $ResourceGroupName,
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string] $TemplateFile,
        [Parameter(Position = 3, Mandatory = $true)]
        [string] $TemplateParameterFile,
        [Parameter()]
        [switch] $Pipeline
    )

    Try{
        $null = Get-AzureRMContext
        }
    Catch {
        Throw "AzureRM module is not loaded or no connection is made with Azure. Please connect to Azure"
    }

    $DebugPreference = "SilentlyContinue"

    #set variables
    $Output = $null
    $DetailedError = $null
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
    }

    $Output = Test-AzureRmResourceGroupDeployment @parameters

    #Check for a specific output. This output is a very generic error-message.
    #So this script looks for the more clear errormessage in the AzureLogs.
    if ($Output.Message -like "*s not valid according to the validation procedure*") {
        Write-output "the output is a generic error message. The log is searched for a more clear errormessage"
        Start-Sleep 30
        #use regex to find the ID of the log
        $Regex = '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
        $IDs = $Output.Message | Select-String $Regex -AllMatches
        $trackingID = $IDs.Matches.Value | select-object -Last 1

        #Get Relevant logentry
        $LogContent = (Get-AzureRMLog -CorrelationId $trackingID -WarningAction ignore).Properties.Content
        $DetailedError = $LogContent[0].statusMessage
        $ErrorCode = ($DetailedError | convertfrom-json ).error.details.code
        $ErrorMessage = ($DetailedError | convertfrom-json ).error.details.message
    }

    if ($Output) {

        #check if DetailedError has been used. if it is, return the value
        if (-not[string]::IsNullOrEmpty($DetailedError))  {
            Write-Output "General Error. Find info below:"
            Write-Output "ErrorCode: $ErrorCode"
            Write-Output "Errormessage: $ErrorMessage"
        }
        #if not, output the original message
        if ([string]::IsNullOrEmpty($DetailedError)) {
            Write-output "Error, Find info below:"
            Write-Output $Output.Message
        }
        #exit code 1 is for Azure DevOps to stop the build in failed state. locally it just stops the script
        if ($Pipeline){
            [Environment]::Exit(1)
        }
    }
    else {
        Write-Output "deployment is correct"
    }

}