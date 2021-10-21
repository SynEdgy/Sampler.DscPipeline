function Get-DscMofVersion
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Path
    )

    process
    {
        if (-not (Test-Path -Path $Path))
        {
            Write-Error "The MOF file '$Path' cannot be found."
            return
        }

        $content = Get-Content -Path $Path

        $xRegistryDscVersion = $content | Select-String -Pattern '\[xRegistry\]DscVersion' -Context 0, 10

        if (-not $xRegistryDscVersion)
        {
            Write-Error "No version information found in MOF file '$Path'. The version information must be added using the 'xRegistry' named 'DscVersion'."
            return
        }

        $valueData = $xRegistryDscVersion.Context.PostContext | Select-String -Pattern 'ValueData' -Context 0, 1
        if (-not $valueData)
        {
            Write-Error "Found the resource 'xRegistry' named 'DscVersion' in '$Path' but no ValueData in the expected range (10 lines after defining '[xRegistry]DscVersion'."
            return
        }

        try
        {
            $value = $valueData.Context.PostContext[0].Trim().Replace('"', '')
            [String]$value
        }
        catch
        {
            Write-Error "ValueData could not be converted into 'System.Version'. The value taken from the MOF file was '$value'"
            return
        }
    }
}
