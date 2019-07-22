
<#
.SYNOPSIS
Returns a HashTable with all properties of an object, including nested properties

.DESCRIPTION
This function goes through all properties and puts them on one level.

.PARAMETER Object
Mandatory - The object to list properties of

.PARAMETER MaxLevels
Specifies how many levels deep to list

.PARAMETER PathName
Specifies the path name to use as the root. If not specified, all properties will start with "."

.PARAMETER Level
Specifies which level the function is currently processing. Should not be used manually.

.EXAMPLE
Get-ResourceProperty -Object $Resource

.NOTES
This is a modification of a script by KevinD.
http://stackoverflow.com/users/1298933/kevind
Source: https://stackoverflow.com/questions/22388226/powershell-script-delete-first-character-in-output
Modified by: Barbara Forbes
Module: ARMHelper
https://4bes.nl
@Ba4bes
#>
function Get-ResourceProperty {
    [CmdletBinding()]
    param (
        [Parameter(Position = 1, Mandatory = $true)]
        [psobject] $Object,
        [Parameter()]
        [int] $MaxLevels = 10,
        [Parameter()]
        [string] $PathName = "",
        [Parameter()]
        [int] $Level = 0
    )
    #Initialize an array to store properties
    $Props = @()
    if ($Level -eq 0) {
        $PropertiesReadable = @{ }
    }
    $RootProperties = $Object | Get-Member -MemberType NoteProperty

    # Make sure we're not exceeding the MaxLevels
    if ($Level -lt $MaxLevels) {

        # Properties of the following types don't need another loop
        $TypesToWrite = "System.Boolean", "System.String", "System.Int32", "System.Char"

        #Loop through the root properties
        foreach ($RootProperty in $RootProperties) {

            #Base name of property
            $Propname = $RootProperty.Name

            #Object to process
            $PropertyObject = $($Object.$Propname)
            if ($Null -eq $PropertyObject) {
                Continue
            }
            # Get the type, and only recurse into it if it is not one of our excluded types
            $Type = ($PropertyObject.GetType()).tostring()
            $Array = ($PropertyObject.GetType()).BaseType.tostring()

            # If it's an array, go through each object
            if ($Array -eq "System.Array") {
                foreach ($PropObject in $PropertyObject) {
                    $Key = $PropObject.Name
                    $Value = $PropObject.Value
                    if ([string]::IsNullOrEmpty($key)) {
                        continue
                    }
                    if ([string]::IsNullOrEmpty($Value)) {
                        $Members = ($PropObject | get-member -Type NoteProperty | Where-Object { $_.Name -ne "Name" }).Name
                        $Value = $PropObject.$Members
                    }
                    if ($PropertiesReadable.$Key) {
                        $Path = $PathName.Replace(".properties", "")
                        $Key = "$Path.$($PropObject.Name)"
                    }
                    if ($SecureParameters -contains $Key) {
                        # This is a bit of a workaround to avoid a plaintext securestring
                        # The only thing that's better is that this doesn't trigger PSScriptAnalyzer :')
                        $SecValue = New-Object SecureString
                        [char[]]($Value) | ForEach-Object { $SecValue.AppendChar($_) }
                        $Value = $SecValue
                    }
                    $PropertiesReadable.add($Key, $Value)
                    Continue
                }
            }
            #If $TypesToWrite containt the type, write results to hashtable
            Elseif (($TypesToWrite.Contains($Type) ) ) {

                $Props += "$PathName.$($RootProperty.Name)"
                $Key = $RootProperty.Name
                $Value = $PropertyObject

                # Add tags for readability
                if ($PathName -like "*Tags*") {
                    $Key = "Tags: $($RootProperty.Name)"

                }
                if ($PropertiesReadable.$Key) {
                    $Path = $PathName.Replace(".properties", "")
                    $Key = "$Path.$($RootProperty.Name)"
                }
                if ($SecureParameters -contains $Key) {
                    # This is a bit of a workaround to avoid a plaintext securestring
                    # The only thing that's better is that this doesn't trigger PSScriptAnalyzer :')
                    $SecValue = New-Object SecureString
                    [char[]]($Value) | ForEach-Object { $SecValue.AppendChar($_) }
                    $Value = $SecValue
                }
                $PropertiesReadable.add($Key, $Value)
            }
            # If $TypesToWrite does not contain the type, recurse.
            Elseif (-not($TypesToWrite.Contains($Type) ) ) {
                #Create a new path to the property
                $ChildPathName = "$PathName.$Propname"

                # Make sure it's not null, then recurse, incrementing $Level
                if ($Null -ne $PropertyObject) {
                    $Props += Get-ResourceProperty -Object $PropertyObject -PathName $ChildPathName -Level ($Level + 1) -MaxLevels $MaxLevels
                }
            }
        }
    }
    $PropertiesReadable
}
