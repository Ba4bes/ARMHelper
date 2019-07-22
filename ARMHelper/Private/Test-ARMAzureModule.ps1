Function Test-ARMAzureModule {

    $Module = $null
    $AzureRM = get-installedModule AzureRM -ErrorAction SilentlyContinue
    $Az = Get-InstalledModule AZ -ErrorAction SilentlyContinue

    if (-not[string]::IsNullOrEmpty($Az)) {
        Write-Verbose "Az is found"
        try {
            $null = Get-AzContext
        }
        Catch {
            Throw "No connection with Az has been found. Please Connect."
        }
        $Module = "Az"
    }

    if (-not[string]::IsNullOrEmpty($AzureRM)) {
        Write-Verbose "AzureRM is found"
        try {
            $null = Get-AzureRmContext
        }
        Catch {
            Throw "No connection with AzureRM has been found. Please Connect."
        }
        $Module = "AzureRM"
    }
    if ([string]::IsNullOrEmpty($Module)) {
        Write-Error "neither AZ of AzureRM could be loaded"
    }
    $Module


}