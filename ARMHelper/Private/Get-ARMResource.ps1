Function Get-ARMResource {
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

    try {
        $null = Get-AzureRmContext
    }
    Catch {
        Throw "No connection with AzureRM has been found. Please Connect."
    }

    $Output = $null
    #set debugpreference to continue so the Test-AzureRmResourceGroupDeployment runs with more output
    $DebugPreference = "Continue"

    $Output = Test-AzureRmResourceGroupDeployment @parameters 5>&1 -ErrorAction Stop

    #Set DebugPreference back to normal
    $DebugPreference = "SilentlyContinue"
    if ([string]::IsNullOrEmpty($Output)) {
        Throw "Something went wrong, Test-AzureRmResourceGroupDeployment didn't give output"
    }
    #Grap the specific part of the output that tells you about the deployed Resources
    $Response = $Output | Where-Object { $_.Message -like "*http response*" }
    #get the jsonpart en convert it to work with it.
    $Result = (($Response -split "Body:")[1] | ConvertFrom-Json).Properties

    $Result
}