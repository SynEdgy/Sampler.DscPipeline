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
    $DatumConfigDataDirectory = (property DatumConfigDataDirectory 'source'),

    [Parameter()]
    [int]
    $CurrentJobNumber = (property CurrentJobNumber 1),

    [Parameter()]
    [int]
    $TotalJobCount = (property TotalJobCount 1),

    # Build Configuration object
    [Parameter()]
    [System.Collections.Hashtable]
    $BuildInfo = (property BuildInfo @{ }),

    [Parameter()]
    [string]
    $RsopFolder = (property RsopFolder 'RSOP'),

    [Parameter()]
    [string]
    $ModuleVersion = (property ModuleVersion '')
)

task CompileDatumRsop {
    # Get the vales for task variables, see https://github.com/gaelcolas/Sampler#task-variables.
    . Set-SamplerTaskVariable -AsNewBuild

    $DatumConfigDataDirectory = Get-SamplerAbsolutePath -Path $DatumConfigDataDirectory -RelativeTo $ProjectPath
    $RsopFolder = Get-SamplerAbsolutePath -Path $RsopFolder -RelativeTo $OutputDirectory

    if (-not (Test-Path -Path $RsopFolder))
    {
        $null = New-Item -ItemType Directory -Path $RsopFolder -Force
    }

    $rsopOutputPathVersion = Join-Path -Path $RsopFolder -ChildPath $ModuleVersion

    if (-not (Test-Path -Path $rsopOutputPathVersion))
    {
        $null = New-Item -ItemType Directory -Path $rsopOutputPathVersion -Force
    }

    if ($configurationData.AllNodes)
    {
        Write-Build Green "Generating RSOP output for $($configurationData.AllNodes.Count) nodes."
        $configurationData.AllNodes.Where({$_['Name'] -ne '*'}) | ForEach-Object -Process {
            Write-Build Green "`tBuilding RSOP for $($_['NodeName'])..."
            $nodeRSOP = Get-DatumRsop -Datum $datum -AllNodes ([ordered]@{ } + $_)
            $nodeRSOP | ConvertTo-Json -Depth 40 | ConvertFrom-Json | Convertto-Yaml -OutFile (Join-Path -Path $rsopOutputPathVersion -ChildPath "$($_['NodeName']).yml") -Force
        }
    }
    else
    {
        Write-Build Green "No data for generating RSOP output."
    }
}
