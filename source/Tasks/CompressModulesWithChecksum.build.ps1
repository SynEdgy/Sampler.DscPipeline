param
(
    # Project path
    [Parameter()]
    [System.String]
    $ProjectPath = (property ProjectPath $BuildRoot),

    [Parameter()]
    # Base directory of all output (default to 'output')
    [System.String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [string]
    $RequiredModulesDirectory = (property RequiredModulesDirectory 'RequiredModules'),

    [Parameter()]
    [string]
    $CompressedModulesFolder = (property CompressedModulesFolder 'CompressedModules'),

    [Parameter()]
    [int]
    $CurrentJobNumber = (property CurrentJobNumber 1),

    [Parameter()]
    [int]
    $TotalJobCount = (property TotalJobCount 1),

    # Build Configuration object
    [Parameter()]
    [System.Collections.Hashtable]
    $BuildInfo = (property BuildInfo @{ })
)

task CompressModulesWithChecksum {
    . Set-SamplerTaskVariable -AsNewBuild
    
    $CompressedModulesFolder = Get-SamplerAbsolutePath -Path $CompressedModulesFolder -RelativeTo $OutputDirectory
    $RequiredModulesDirectory = Get-SamplerAbsolutePath -Path $RequiredModulesDirectory -RelativeTo $OutputDirectory

    if ($SkipCompressedModulesBuild)
    {
        Write-Host 'Skipping preparation of Compressed Modules as $SkipCompressedModulesBuild is set'
        return
    }

    if (-not (Test-Path -Path $CompressedModulesFolder))
    {
        $null = New-Item -Path $CompressedModulesFolder -ItemType Directory -Force
    }

    if ($SkipCompressedModulesBuild)
    {
        Write-Host 'Skipping preparation of Compressed Modules as $SkipCompressedModulesBuild is set'
        return
    }

    if ($configurationData.AllNodes -and $CurrentJobNumber -eq 1)
    {
        
        $modules = Get-ModuleFromFolder -ModuleFolder $RequiredModulesDirectory | Where-Object -FilterScript {
            $null -ne $_.ExportedDscResources
        } # Only zip up the Modules that have Exported DSC Resources
        #TODO: be more selective and maybe check based on the MOFs (but that's a lot of MOF to parse)

        foreach ($module in $modules)
        {
            $destinationPath = Join-Path -Path $CompressedModulesFolder -ChildPath "$($module.Name)_$($module.Version).zip"
            Compress-Archive -Path "$($module.ModuleBase)\*" -DestinationPath $destinationPath
            $hash = (Get-FileHash -Path $destinationPath).Hash
        
            try
            {
                $stream = New-Object -TypeName System.IO.StreamWriter("$destinationPath.checksum", $false)
                [void] $stream.Write($hash)
            }
            finally
            {
                if ($stream)
                {
                    $stream.Close()
                }
            }
        }
    }
    else
    {
        Write-Build Green "No data in 'ConfigurationData.AllNodes', skipping task 'CompressModulesWithChecksum'."
    }
}
