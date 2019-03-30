
function Get-ReSourceProperties($Object, $MaxLevels = "10", $PathName = "", $Level = 0) {
    <#
        .SYNOPSIS
        Returns a list of all properties of the input object

        .DESCRIPTION
        Recursively

        .PARAMETER Object
        Mandatory - The object to list properties of

        .PARAMETER MaxLevels
        Specifies how many levels deep to list

        .PARAMETER PathName
        Specifies the path name to use as the root. If not specified, all properties will start with "."

        .PARAMETER Level
        Specifies which level the function is currently processing. Should not be used manually.

        .EXAMPLE
        $v = Get-View -ViewType VirtualMachine -Filter @{"Name" = "MyVM"}
        Get-Properties $v | ? {$_ -match "Host"}

        .NOTES
            FunctionName :
            Created by   : KevinD
            Date Coded   : 02/19/2013 12:54:52
        .LINK
            http://stackoverflow.com/users/1298933/kevind
     #>

    #Initialize an array to store properties
    $props = @()
    if ($level -eq 0) {
        $PropertiesReadable = @{ }
    }

    # Get all properties of this level
    #   $rootProps = $Object | Get-Member -ErrorAction SilentlyContinue | Where-Object { $_.MemberType -match "Property"}
    # if ($object.GetType() -eq "System.Array") {
    #     foreach ($prop in $object){
    #         $rootProps += $prop
    #     }
    # }
    $rootProps = $Object | Get-Member -MemberType NoteProperty
    # Add all properties from this level to the array.
    # $rootProps | ForEach-Object { $props += "$PathName.$($_.Name)" }
    #   ForEach ($RootProp in $RootProps){

    #     $props += "$PathName.$($RootProp.Name)"
    #   }

    # Make sure we're not exceeding the MaxLevels
    if ($Level -lt $MaxLevels) {
        # ForEach ($RootProp in $RootProps){

        #     $props += "$PathName.$($RootProp.Name)"
        #   }

        # We don't care about the sub-properties of the following types:
        $typesToExclude = "System.Boolean", "System.String", "System.Int32", "System.Char"

        #Loop through the root properties
        #  $props += $rootProps | ForEach-Object  {
        foreach ($RootProp in $RootProps) {
            #          $props += "$PathName.$($RootProp.Name)"
            #    $props += "$PathName.$($_.Name)"
            #Base name of property
            $propName = $RootProp.Name

            #Object to process
            $obj = $($Object.$propName)

            # Get the type, and only recurse into it if it is not one of our excluded types
            $type = ($obj.GetType()).tostring()
            $Array = ($obj.GetType()).BaseType.tostring()
            # Only recurse if it's not of a type in our list
            if ($Array -eq "System.Array") {
                foreach ($ob in $obj) {

                    #$props += "$PathName.$($RootProp.Name)"
                    $key = $ob.Name
                    $Value = $ob.Value

                    if ($PropertiesReadable.$key) {
                        $Path = $PathName.Replace(".properties", "")
                        $key = "$Path.$($ob.Name)"
                    }
                        $PropertiesReadable.add($key, $value)

                    }
                }


            Elseif (($typesToExclude.Contains($type) ) ) {

                $props += "$PathName.$($RootProp.Name)"
                $key = $rootProp.Name
                $Value = $obj


                if ($PropertiesReadable.$key) {
                    $Path = $PathName.Replace(".properties", "")
                    $key = "$Path.$($RootProp.Name)"
                }
                $PropertiesReadable.add($key, $value)

            }
            Elseif (!($typesToExclude.Contains($type) ) ) {

                #Path to property
                $childPathName = "$PathName.$propName"

                # Make sure it's not null, then recurse, incrementing $Level
                if ($obj -ne $null) {
                    $props += Get-ResourceProperties -Object $obj -PathName $childPathName -Level ($Level + 1) -MaxLevels $MaxLevels
                }
            }
        }

    }
    $PropertiesReadable
}

