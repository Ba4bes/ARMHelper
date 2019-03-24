Function Get-PropertiesVirtualMachines {
    param (
        # Parameter help description
        [Parameter(Position = 1)]
        [PSObject]$Resource
    )
    $Properties = $Resource.Properties | get-member -MemberType NoteProperty
    $PropertiesReadable = @{}
    foreach ($Property in $Properties) {
        write-output "loop starting"
        Write-output $propname

        $propadded = $false
        $propname = $Property.Name
        $key = $propname
        $value = $($Resource.Properties.$propname)
        if ($propname -eq "hardwareProfile"){
            $key = "vmSize"
            $value = $resource.properties.hardwareProfile.vmSize
            $PropertiesReadable.add($key, $value)
            $propadded = $true
        }
        if ($propname -eq "networkprofile"){
            $key = "NetworkInterfaces"
            $value = $resource.properties.networkProfile.networkInterfaces.id
            $PropertiesReadable.add($key, $value)
            $propadded = $true
        }
        if ($propname -eq "osProfile"){
            $key = "ComputerName"
            $value = $resource.properties.osProfile.computerName
            $PropertiesReadable.add($key, $value)

            $key = "AdminUserName"
            $value = $resource.properties.osProfile.adminUsername
            $PropertiesReadable.add($key, $value)

            $key = "AdminPassword"
            $value = $resource.properties.osProfile.adminPassword
            $PropertiesReadable.add($key, $value)
            if ($resource.properties.osProfile.windowsConfiguration){
                $key = "Automatic updates enabled"
                $value = $resource.properties.osProfile.windowsConfiguration.enableAutomaticUpdates
                $PropertiesReadable.add($key, $value)
                $key = "ProvisionVMagent"
                $value = $resource.properties.osProfile.windowsConfiguration.provisionVmAgent
                $PropertiesReadable.add($key, $value)
            }
            $propadded = $true
        }
        if ($propname -eq "storageProfile"){

            $key = "Create option"
            $value = $resource.properties.storageProfile.osDisk.createOption
            $PropertiesReadable.add($key, $value)

            $key = "Storage Account Type"
            $value = $resource.properties.storageProfile.osDisk.managedDisk.storageAccountType
            $PropertiesReadable.add($key, $value)
            $propadded = $true
        }
            # foreach ($config in  $resource.properties.ipConfigurations) {
            #     $key = "SubnetID  $($config.name)"
            #     $value = $config.properties.subnet.id
            #     $PropertiesReadable.add($key, $value)

            #     $key = "Private IP $($config.name)"
            #     $value = $config.properties.privateIPAddress
            #     $PropertiesReadable.add($key, $value)

            #     $key = "Private IP allocation $($Config.name)"
            #     $value = $config.properties.privateIPAllocationMethod
            #     $PropertiesReadable.add($key, $value)

            #     $key = "Public IP id $($Config.name)"
            #     $value = $config.properties.publicIpAddress.id
            #     $PropertiesReadable.add($key, $value)
            #}

            if ($propadded -eq $false) {

            $PropertiesReadable.add($key, $value)
                }

    }
    # Write-Output "Properties:"
    # $PropertiesReadable
    Return $PropertiesReadable
}