Function Get-PropertiesnetworkSecurityGroup {
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
    if ($propname -eq "securityRules" ){
        foreach ($rule in ($Resource.properties.securityRules)){
            $key = "$propname : " + $rule.name
            $value = $rule.properties
  #          $value = "$($values.access) Protocol $($values.protocol),source $($values.SourcePortRage) port $($values.) "

            $PropertiesReadable.add($key, $value)
            }


    }
    else {
    $PropertiesReadable.add($key, $value)
    }
}
# Write-Output "Properties:"
# $PropertiesReadable
Return $PropertiesReadable
}