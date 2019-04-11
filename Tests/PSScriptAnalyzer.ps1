<#
.SYNOPSIS
    Run PSScriptAnalyzertests against all scripts
.DESCRIPTION
    This scripts runs check with PSScriptanalyzer.
.PARAMETER ScriptPath
    The Path where the scripts are. This could be the whole repository or a specific Scriptfolder.
.PARAMETER Exclusions
    Define values that don't need to be checked, because they are and accepted risk. For example: PSAvoidUsingUserNameAndPassWordParams if using a lab environment
.PARAMETER Manual
    If used, more tests will be ran. These tests check best practices, but aren't needed to run the script through the build.
.EXAMPLE
    .\PSScriptAnalyzer.ps1 -ScriptPath C:\Scripts\ExampleRepo -Exclusions PSAvoidUsingUserNameAndPassWordParams -Manual
    Script will run manually and provide all testresults. Rule PSAvoidUsingUserNameAndPassWordParams will be ignored
.NOTES
    This script is written to use in a build pipeline, but can be ran manually without issues.
    Written for OGD ict-diensten for internal use, by Barbara Forbes
#>

Param(
    [Parameter(Mandatory = $true)]
    [String]$ScriptPath,
    [Parameter()]
    [String[]]$Exclusions,
    # Parameter help description
    [Parameter()]
    [Switch]$Manual
)

$Scripts = Get-ChildItem $ScriptPath -Include *.ps1, *.psm1, *.psd1 -Recurse
$ErrorFound = $false
foreach ($Script in $Scripts) {
    Write-Output  "Checking $($Script.FullName)"
    $PSScriptAnalyzer = Invoke-ScriptAnalyzer -Path $Script.fullname
    if ($Manual) {
        $PSScriptAnalyzer
        continue
    }

    Foreach ($Result in $PSScriptAnalyzer) {
        if (($Result.Severity -eq "Error") -and ($Exclusions -notcontains $Result.RuleName) ) {
            Write-Output "Rule triggered:"
            Write-Output $Result
            $ErrorFound = $true
        }
    }
}

if ($ErrorFound -eq $true) {
    Exit 1
}
else {
    Write-Output "No errors found"
}
