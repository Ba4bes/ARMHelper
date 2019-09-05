<#
.SYNOPSIS
Tests an azure deployment for errors, Use the azure Logs if a generic message is given.

.DESCRIPTION
This function uses Test-AzureRmResourceGroupDeployment or Test-AZResourcegroupDeployment. There is a specific errormessage that's very generic.
If this is the output, the correct errormessage is retrieved from the Azurelog.

.PARAMETER ResourceGroupName
The resourcegroup where the resources would be deployed to. This resourcegroup needs to exist.

.PARAMETER TemplateFile
The path to the templatefile

.PARAMETER TemplateParameterFile
The path to the parameterfile, optional

.PARAMETER TemplateParameterObject
A Hasbtable with parameters, optional

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
Get-ARMDeploymentErrorMessage Armtesting .\VM01\azuredeploy.json -TemplateParameterObject $Parameters

--------
deployment is correct

.NOTES
Dynamic Parameters like in the orginal Test-AzResourcegroupDeployment-cmdlet are supported
Author: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
#>
function Get-ARMDeploymentErrorMessage {
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
        [Parameter(
            ParameterSetName = "__AllParameterSets"
        )]
        [switch] $Pipeline,

        [Parameter(
            ParameterSetName = "__AllParameterSets"
        )]
        [switch] $ThrowOnError
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


        if ($Pipeline) {
            Write-Warning "This parameter will be removed in the next release. Please use -ThrowOnError as an replacement"
        }

        #set variables
        $Output = $null
        $DetailedError = $null
        $Parameters = @{
            ResourceGroupName = $ResourceGroupName
            TemplateFile      = $TemplateFile
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

}
