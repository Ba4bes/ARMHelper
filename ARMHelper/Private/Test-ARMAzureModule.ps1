Function Test-ARMAzureModule {

    $Module = $null
    $AzureRMLoaded = Get-Module -Name AzureRM.*
    $AzLoaded = Get-Module -Name Az.*
    $AzureRM = get-installedModule AzureRM -ErrorAction SilentlyContinue
    $Az = Get-InstalledModule AZ -ErrorAction SilentlyContinue

    if ((-not[string]::IsNullOrEmpty($Az)) -or (-not[string]::IsNullOrEmpty($AzLoaded)) ) {
        Write-Verbose "Az is found"
        try {
            $null = Get-AzContext
        }
        Catch {
            Throw "No connection with Az has been found. Please Connect."
        }
        $Module = "Az"
    }
    Elseif ((-not[string]::IsNullOrEmpty($AzureRM)) -or (-not[string]::IsNullOrEmpty($AzureRMLoaded)) ) {
        Write-Verbose "AzureRM is found"
        try {
            $null = Get-AzureRmContext
        }
        Catch {
            Throw "No connection with AzureRM has been found. Please Connect."
        }
        $Module = "AzureRM"
    }
    Else {
        Throw "neither AZ of AzureRM could be loaded"
    }
    $Module


}
# Function Test-ARMAzureModule {

#     $Module = $null
#      # First, check if the module is already loaded
#     $AzureRMLoaded = Get-Module -Name AzureRM.*
#     $AzLoaded = Get-Module -Name Az.*

#     $AzureRM = Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue
#     $Az = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue
#     if ((-not[string]::IsNullOrEmpty($Az)) -or (-not[string]::IsNullOrEmpty($AzLoaded)) ) {
#         Write-Verbose "Az is found"
#         try {
#             $null = Get-AzContext
#         }
#         Catch {
#             Throw "No connection with Az has been found. Please Connect."
#         }
#         $Module = "Az"
#     }
#     elseif ((-not[string]::IsNullOrEmpty($AzureRM)) -or (-not[string]::IsNullOrEmpty($AzurermLoaded))) {
#         Write-Verbose "AzureRM is found"
#         try {
#             $null = Get-AzureRmContext
#         }
#         Catch {
#             Throw "No connection with AzureRM has been found. Please Connect."
#         }
#         $Module = "AzureRM"
#     }
#     else {
#         Throw "neither AZ of AzureRM could be loaded"
#     }

#     $Module
# }
# Function Test-ARMAzureModule {

#     $Module = $null

#     # First, check if the module is already loaded
#     $AzureRMLoaded = Get-Module -Name AzureRM.*
#     $AzLoaded = Get-Module -Name Az.*

#     if (-not[string]::IsNullOrEmpty($AzLoaded)) {
#         Write-Verbose "Az is found"
#         $Module = "Az"
#         Continue
#     }
#     else {
#         $Az = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue
#         if (-not[string]::IsNullOrEmpty($Az)) {
#             Write-Verbose "Az is found, but not imported. Importing now"
#             Try {
#                 Import-Module Az -force
#                 $Module = "Az"
#                 Continue
#             }
#             Catch {
#                 Throw "Could not import Module Az"
#             }
#         }
#         elseif (-not[string]::IsNullOrEmpty($AzureRMLoaded)) {
#             Write-Verbose "AzureRM is found"
#             $Module = "AzureRM"
#             Continue
#         }
#         else {
#             $AzureRM = Get-InstalledModule -Name AzureRM -ErrorAction SilentlyContinue
#             if (-not[string]::IsNullOrEmpty($AzureRM)) {
#                 Write-Verbose "AzureRM is found, but not imported. Importing now"
#                 Try {
#                     Import-Module AzureRM -force
#                     $Module = "AzureRM"
#                     Continue
#                 }
#                 Catch {
#                     Throw "Could not import Module AzureRM"
#                 }
#             }
#         }
#     }

#     if ($Module -eq "Az") {
#         Try {
#             Write-Verbose "GetazContext"
#             $null = Get-AzContext
#         }
#         Catch {
#             Throw "No connection with $Module has been found. Please Connect."
#         }
#     }
#     elseif ($Module -eq "AzureRM") {
#         Try {
#             Write-Verbose "GetazurermContext"
#             $null = Get-AzureRMContext
#         }
#         Catch {
#             Throw "No connection with $Module has been found. Please Connect."
#         }
#     }
#     else {
#         Throw  "neither AZ of AzureRM could be loaded"
#     }
#     $Module
# }