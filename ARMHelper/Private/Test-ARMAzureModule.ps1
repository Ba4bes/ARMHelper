Function Test-ARMAzureModule {

    $Module = $null
    $AzLoaded = Get-Module -Name Az.*
    $AzureRMLoaded = Get-Module -Name AzureRM.*
    if (-not[string]::IsNullOrEmpty($AzLoaded)) {
        $Module = "Az"
    }
    elseif (-not[string]::IsNullOrEmpty($AzureRMLoaded)) {
        $Module = "AzureRM"
    }
    Else {
        $Az = Get-InstalledModule AZ -ErrorAction SilentlyContinue
        $AzureRM = get-installedModule AzureRM -ErrorAction SilentlyContinue
        If (-not[string]::IsNullOrEmpty($Az)) {
            $Module = "Az"
        }
        Elseif (-not[string]::IsNullOrEmpty($AzureRM)) {
            $Module = "AzureRM"
        }
    }
    Write-Verbose "Az is found"
    try {
        if ($Module -eq "Az") {
            $null = Get-AzContext
        }
        elseif ($Module -eq "AzurRM") {
            $null = Get-AzureRMContext
        }
    }
    Catch {
        Throw "No connection with Az has been found. Please Connect."
    }

    if ([string]::IsNullOrEmpty($Module)) {
        Throw "neither AZ of AzureRM could be loaded"
    }
    $Module
}