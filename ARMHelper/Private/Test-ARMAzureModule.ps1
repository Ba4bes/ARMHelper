Function Test-ARMAzureModule {

    $Module = $null
    $AzureRM = Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue
    $Az = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue
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
    elseif (-not[string]::IsNullOrEmpty($AzureRM)) {
        Write-Verbose "AzureRM is found"
        try {
            $null = Get-AzureRmContext
        }
        Catch {
            Throw "No connection with AzureRM has been found. Please Connect."
        }
        $Module = "AzureRM"
    }
    else {
        Throw "neither AZ of AzureRM could be loaded"
    }

    $Module
}