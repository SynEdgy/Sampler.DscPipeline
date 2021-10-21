
function Get-DscMofEnvironment
{
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

        $xRegistryDscEnvironment = $content | Select-String -Pattern '\[xRegistry\]DscEnvironment' -Context 0, 10
        if (-not $xRegistryDscEnvironment)
        {
            Write-Error "No environment information found in MOF file '$Path'. The environment information must be added using the 'xRegistryx' named 'DscEnvironment'."
            return
        }

        $valueData = $xRegistryDscEnvironment.Context.PostContext | Select-String -Pattern 'ValueData' -Context 0, 1
        if (-not $valueData)
        {
            Write-Error "Found the resource 'xRegistry' named 'DscEnvironment' in '$Path' but no ValueData in the expected range (10 lines after defining '[xRegistry]DscEnvironment'."
            return
        }

        $valueData.Context.PostContext[0].Trim().Replace('"', '')
    }
}
