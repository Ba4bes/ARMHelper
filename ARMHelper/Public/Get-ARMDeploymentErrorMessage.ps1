<#
.SYNOPSIS
Tests an azure deployment for errors, Use the azure Logs if a generic message is given.

.DESCRIPTION
This function uses Test-AzureRmResourceGroupDeployment or Test-AZResourcegroupDeployment. There is a specific errormessage that's very generic.
If this is the output, the correct errormessage is retrieved from the Azurelog

.PARAMETER ResourceGroupName
The resourcegroup where the resources would be deployed to. This resourcegroup needs to exist.

.PARAMETER TemplateFile
The path to the deploymentfile

.PARAMETER TemplateParameterFile
The path to the parameterfile

.PARAMETER Pipeline
Use this parameter if this script is used in a CICDpipeline. It will make the step fail.
This parameter is replaced by ThrowOnError and will be removed in a later release!

.PARAMETER ThrowOnError
This Switch will make the cmdlet throw when the deployment is incorrect. This can be useful in a pipeline, it will make the task fail.

.EXAMPLE
Get-ARMDeploymentErrorMessage -ResourceGroupName ArmTest -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json

--------
the output is a generic error message. The log is searched for a more clear errormessageGeneral Error. Find info below:
ErrorCode: InvalidDomainNameLabel
Errormessage: The domain name label LABexample is invalid. It must conform to the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.

.EXAMPLE
Get-ARMDeploymentErrorMessage Armtesting .\VM01\azuredeploy.json .\VM01\azuredeploy.parameters.json

--------
deployment is correct

.NOTES
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
#>
function Get-ARMDeploymentErrorMessage {
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
        [Parameter()]
        [switch] $Pipeline,
        [Parameter()]
        [switch] $ThrowOnError
    )
    if ($Pipeline) {
        Write-Warning "This parameter will be removed in the next release. Please use -ThrowOnError as an replacement"
    }

    #set variables
    $Output = $null
    $DetailedError = $null
    $Parameters = @{
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $TemplateParameterFile
    }

    #Get the AzureModule that's being used
    $Module = Test-ARMAzureModule
    try {
        if ($Module -eq "Az") {
            $Output = Test-AzResourceGroupDeployment @parameters
        }
        elseif ($Module -eq "AzureRM") {
            $Output = Test-AzureRmResourceGroupDeployment @parameters
        }
        else {
            Throw "Something went wrong, No AzureRM of AZ module found"
        }
    }
    catch {
        throw "Could not test deployment because of following error $_"
    }

    #Check for a specific output. This output is a very generic error-message.
    #So this script looks for the more clear errormessage in the AzureLogs.
    if ($Output.Message -like "*s not valid according to the validation procedure*") {
        Write-Output "the output is a generic error message. The log is searched for a more clear errormessage"
        #use regex to find the ID of the log
        $Regex = '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
        $IDs = $Output.Message | Select-String $Regex -AllMatches
        $trackingID = $IDs.Matches.Value | Select-Object -Last 1
        $MaxTries = 0
        do {
            Start-Sleep 30
            Write-Output "The log is searched."

            if ($Module -eq "Az") {
                $LogContent = (Get-AzLog -CorrelationId $trackingID -WarningAction ignore).Properties.Content
            }
            elseif ($Module -eq "AzureRM") {
                $LogContent = (Get-AzureRmLog -CorrelationId $trackingID -WarningAction ignore).Properties.Content
            }
            else {
                Throw "Something went wrong, No AzureRM of AZ module found"
            }
            $MaxTries ++
        } while ($null -eq $LogContent -and $maxtries -le 5)

        if ($maxtries -gt 5 ) {
            Throw "Can't get Azure Log Entry. Please check the log manually in the portal."
        }
        $DetailedError = $LogContent[0].statusMessage
        $TestError = ($DetailedError | ConvertFrom-Json ).error.details.details
        if ([string]::IsNullOrEmpty($testError)) {
            $ErrorCode = ($DetailedError | ConvertFrom-Json ).error.details.code
            $ErrorMessage = ($DetailedError | ConvertFrom-Json ).error.details.message
        }
        else {
            $ErrorCode = ($DetailedError | ConvertFrom-Json ).error.details.details.code
            $ErrorMessage = ($DetailedError | ConvertFrom-Json ).error.details.details.message
        }
    }

    if (-not [string]::IsNullOrEmpty($Output) ) {
        #check if DetailedError has been used. if it is, return the value
        if (-not[string]::IsNullOrEmpty($DetailedError)) {
            Write-Output "General Error. Find info below:"
            Write-Output "ErrorCode: $ErrorCode"
            Write-Output "Errormessage: $ErrorMessage"
        }
        #if not, output the original message
        if ([string]::IsNullOrEmpty($DetailedError)) {
            Write-Output "Error, Find info below:"
            Write-Output $Output.Message
        }
        #exit code 1 is for Azure DevOps to stop the build in failed state. locally it just stops the script
        if ($Pipeline) {
            [Environment]::Exit(1)
        }
        if ($ThrowOnError) {
            Throw "Deployment is incorrect"
        }
    }
    else {
        Write-Output "deployment is correct"
    }
}
