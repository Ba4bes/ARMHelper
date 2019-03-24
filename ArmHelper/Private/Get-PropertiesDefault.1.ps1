Function Get-PropertiesDefault {
    param (
        # Parameter help description
        [Parameter(Position = 1)]
        [PSObject]$Resource
    )
    $Properties = $Resource.Properties | get-member -MemberType NoteProperty
    $PropertiesReadable = @{}
foreach ($Property in $Properties) {

    $propname = $Property.Name

    $key = $propname
    $value = $($Resource.Properties.$propname)
    $PropertiesReadable.add($key, $value)
}
# Write-Output "Properties:"
# $PropertiesReadable
Return $PropertiesReadable
}