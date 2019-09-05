
Function Get-ARMResource {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    Param(
        [Parameter(
            Position = 1,
            Mandatory = $true,
            ParameterSetName = "__AllParameterSets"
        )]
        [ValidateNotNullorEmpty()]
        [string] $ResourceGroupName,

        [Parameter(
            Position = 2,
            Mandatory = $true,
            ParameterSetName = "__AllParameterSets"
        )]
        [ValidateNotNullorEmpty()]
        [string] $TemplateFile,

        [Parameter(
            ParameterSetName = 'TemplateParameterFile',
            Mandatory = $true
        )]
        [string] $TemplateParameterFile,

        [Parameter(
            ParameterSetName = 'TemplateParameterObject',
            Mandatory = $true
        )]
        [hashtable] $TemplateParameterObject,

        [parameter (
            ParameterSetName = "__AllParameterSets",
            Mandatory = $false
        )]
        [ValidateSet("Incremental", "Complete")]
        [string] $Mode = "Incremental"
    )
    DynamicParam {
        if ($TemplateFile) {
            #create a new ParameterAttribute Object
            $OverRideParameter = New-Object System.Management.Automation.ParameterAttribute
            $OverRideParameter.Mandatory = $false
            #create an attributecollection object for the attribute we just created.
            $AttributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttributeCollection.Add($OverRideParameter)
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $Parameters = (Get-Content $TemplateFile | ConvertFrom-Json).parameters
            $ParameterValues = $parameters | Get-Member -MemberType NoteProperty
            ForEach ($Param in $ParameterValues) {
                $Name = $Param.Name
                $type = ($Parameters.$Name).type
                #add our paramater specifying the attribute collection
                $ExtraParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Param.Name, ($Type -as [type]), $attributeCollection)
               #expose the name of our parameter

                $paramDictionary.Add($Param.Name, $ExtraParam)
            }
            return $paramDictionary
        }
    }
    process {
        #set variables
        $Parameters = @{
            ResourceGroupName = $ResourceGroupName
            TemplateFile      = $TemplateFile
            Mode              = $Mode
        }
        if (-not[string]::IsNullOrEmpty($TemplateParameterFile) ) {
            $Parameters.Add("TemplateParameterFile", $TemplateParameterFile)
        }
        if (-not[string]::IsNullOrEmpty($TemplateParameterObject) ) {
            $Parameters.Add("TemplateParameterObject", $TemplateParameterObject)
        }
        $CustomParameters = (Get-Content $TemplateFile | ConvertFrom-Json).parameters
        $CustomParameterValues = $Customparameters | Get-Member -MemberType NoteProperty
        foreach ($param in $CustomParameterValues) {
            $paramname = $param.Name
            if (-not[string]::IsNullOrEmpty($PSBoundParameters.$paramname)) {
                $Key = $paramname
                $Value = $PSBoundParameters.$paramname
                $Parameters.Add($Key, $Value)
            }
        }
        $Output = $null
        #set debugpreference to continue so the cmdlet runs with more output
        $Module = Test-ARMAzureModule
        $oldDebugPreference = $DebugPreference
        $DebugPreference = "Continue"


        if ($Module -eq "Az") {
            $Output = Test-AzResourceGroupDeployment @parameters 5>&1 -ErrorAction Stop
        }
        elseif ($Module -eq "AzureRM") {
            $Output = Test-AzureRmResourceGroupDeployment @parameters 5>&1 -ErrorAction Stop

        }
        else {
            Throw "Something went wrong, No AzureRM of AZ module found"
        }
        #Set DebugPreference back to original setting
        $DebugPreference = $oldDebugPreference
        if ([string]::IsNullOrEmpty($Output)) {
            Throw "Something went wrong, Test-AzureRmResourceGroupDeployment didn't give output"
        }
        #Grap the specific part of the output that tells you about the deployed Resources
        $Response = $Output | Where-Object { $_.Message -like "*http response*" }
        #get the jsonpart en convert it to work with it.
        $Result = (($Response -split "Body:")[1] | ConvertFrom-Json).Properties

        $Result
    }
}