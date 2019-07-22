
Function Get-ARMResource {
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
    #set variables
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
    $Output = $null
    #set debugpreference to continue so the cmdlet runs with more output
    $Module = Test-ARMAzureModule
    $oldDebugPreference = $DebugPreference
    $DebugPreference = "Continue"


    if ($Module -eq "Az") {
        $Output = Test-AzResourceGroupDeployment @parameters 5>&1 -ErrorAction Stop
    }
    elseif ($Module -eq "AzureRM") {
        $Output = Test-AzureRmResourceGroupDeployment @parameters 5>&1 -ErrorAction Stop

    }
    else {
        Throw "Something went wrong, No AzureRM of AZ module found"
    }
    #Set DebugPreference back to original setting
    $DebugPreference = $oldDebugPreference
    if ([string]::IsNullOrEmpty($Output)) {
        Throw "Something went wrong, Test-AzureRmResourceGroupDeployment didn't give output"
    }
    #Grap the specific part of the output that tells you about the deployed Resources
    $Response = $Output | Where-Object { $_.Message -like "*http response*" }
    #get the jsonpart en convert it to work with it.
    $Result = (($Response -split "Body:")[1] | ConvertFrom-Json).Properties

    $Result
}