Function Test-ARMAzureModule {
    
    $Module = $null
    $AzureRM = get-installedModule AzureRM -ErrorAction SilentlyContinue
    $Az = Get-InstalledModule AZ -ErrorAction SilentlyContinue

    if (-not[string]::IsNullOrEmpty($Az)) {
        Write-Verbose "Az is found"
        if (-not(get-module Az)) {
            Try {
                Import-Module Az
            }
            Catch {
                Write-Error "Az module could not be imported"
            }
        }
        try {
            $null = Get-AzContext
        }
        Catch {
            Throw "No connection with AzureRM has been found. Please Connect."
        }
        $Module = "Az"
    }

    if (-not[string]::IsNullOrEmpty($AzureRM)) {
        Write-Verbose "AzureRM is found"
        if (-not(get-module azureRM)) {
            Try {
                Import-Module AzureRM
            }
            Catch {
                Write-Error "AzureRM module could not be imported"
            }
        }
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

