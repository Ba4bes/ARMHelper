Function Get-PropertiesVirtualNetworks {
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
        # switch ($propname) {
        #     "AddressSpace" {        $key = "Vnet AddressPrefixes"
        #                             $value = $resource.properties.addressSpace.addressPrefixes }
        #     "dhcpOptions"   {       $key = "Vnet DNS-Servers"
        #                             $value = $Resource.properties.dhcpOptions.dnsServers       }
        #     "enableDdosProtection"{ $key = "Vnet DDOS-protection enabled"
        #                             $value = $Resource.properties.enableDdosProtection
        #             }
        #     "subnets" {
        #                 foreach ($subnet in  $Resource.properties.subnets) {
        #                     $key = "Subnet AddressSpace $($subnet.name)"
        #                     $value = $subnet.properties.addressPrefix
        #                     $PropertiesReadable.add($key, $value)

        #                     $key = "Subnet Networksecuritygroup $($subnet.name)"
        #                     $value = $subnet.properties.NetworkSecurityGroup.id
        #                     $PropertiesReadable.add($key, $value)

        #                     $key = "Subnet ServiceEndPoints $($subnet.name)"
        #                     $value = $subnet.properties.serviceEndpoints.Service
        #                     $PropertiesReadable.add($key, $value)
        #                 }
        #                 continue
        #             }
        #     Default {         $key = $propname
        #         $value = $($Resource.Properties.$propname)
        #     }
        # }

        if ($propname -eq "AddressSpace" ) {
            $key = "Vnet AddressPrefixes"
            $value = $resource.properties.addressSpace.addressPrefixes
            #          $value = "$($values.access) Protocol $($values.protocol),source $($values.SourcePortRage) port $($values.) "
 #           $PropertiesReadable.add($key, $value)
        }
        if ($propname -eq "dhcpOptions" ) {
            $key = "Vnet DNS-Servers"
            $value = $Resource.properties.dhcpOptions.dnsServers
 #           $PropertiesReadable.add($key, $value)
        }
        if ($propname -eq "enableDdosProtection" ) {
            $key = "Vnet DDOS-protection enabled"
            $value = $Resource.properties.enableDdosProtection
  #          $PropertiesReadable.add($key, $value)
        }
        if ($propname -eq "Subnets") {
            foreach ($subnet in  $Resource.properties.subnets) {
                $key = "Subnet AddressSpace $($subnet.name)"
                $value = $subnet.properties.addressPrefix
                $PropertiesReadable.add($key, $value)

                $key = "Subnet Networksecuritygroup $($subnet.name)"
                $value = $subnet.properties.NetworkSecurityGroup.id
                $PropertiesReadable.add($key, $value)

                $key = "Subnet ServiceEndPoints $($subnet.name)"
                $value = $subnet.properties.serviceEndpoints.Service
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