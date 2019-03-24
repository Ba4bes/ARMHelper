Function Get-PropertiesNetworkInterfaces {
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
        if ($propname -eq "ipConfigurations"){

            foreach ($config in  $resource.properties.ipConfigurations) {
                $key = "SubnetID  $($config.name)"
                $value = $config.properties.subnet.id
                $PropertiesReadable.add($key, $value)

                $key = "Private IP $($config.name)"
                $value = $config.properties.privateIPAddress
                $PropertiesReadable.add($key, $value)

                $key = "Private IP allocation $($Config.name)"
                $value = $config.properties.privateIPAllocationMethod
                $PropertiesReadable.add($key, $value)

                $key = "Public IP id $($Config.name)"
                $value = $config.properties.publicIpAddress.id
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