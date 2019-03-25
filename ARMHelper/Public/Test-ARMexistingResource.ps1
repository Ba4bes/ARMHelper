Function Test-ARMExistingResource {
    Param(
        [string] [Parameter(Mandatory = $true)] $ResourceGroupName,
        [string] [Parameter(Mandatory = $true)] $TemplateFile,
        [string] [Parameter(Mandatory = $true)] $TemplateParameterFile

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