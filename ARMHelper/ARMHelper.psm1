#Get public and private function definition files.
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
#$Public = @( Get-ChildItem -Path 'C:\Scripts\GIT\Gitlab - Private\DagelijksGehenk\Armado\*.ps1' -ErrorAction SilentlyContinue )


$Scripts = $Private + $Public

#Dot source the files
Foreach ($import in $Scripts) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}