function Get-PropertiesDeployments {
    param (
        # Parameter help description
        [Parameter(Position = 1)]
        [PSObject]$Resource
    )
    $PropertiesReadable = @{}
    $Properties = $Resource.Properties.template.Resources.Properties | get-member -MemberType NoteProperty
    foreach ($Property in $Properties) {

        $propname = $Property.Name
        if ($property.gettype() -eq "System.Array" -or $property.gettype() -eq "System.Object" -or $property.gettype() -eq "Hash" ){
            foreach ($subprop in $property) {
                $key = $propname
                $value = $($Resource.Properties.template.Resources.Properties.$propname)
                $PropertiesReadable.add($key, $value)

            }
        }
        $key = $propname
        $value = $($Resource.Properties.template.Resources.Properties.$propname)
        $PropertiesReadable.add($key, $value)
    }
    Return $PropertiesReadable

}