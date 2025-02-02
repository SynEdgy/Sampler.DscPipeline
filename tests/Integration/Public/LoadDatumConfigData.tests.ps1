BeforeAll {

    Import-Module -Name datum -Force
    Import-Module -Name Sampler.DscPipeline -Force

    $datumPath = (Resolve-Path $ProjectPath\tests\Integration\Assets\ConfigData\Datum.yml).Path

    $datum = New-DatumStructure -DefinitionFile $datumPath
    $environments = $datum.AllNodes | Get-Member -MemberType ScriptProperty | Select-Object -ExpandProperty Name
    $allNodes = foreach ($environment in $environments)
    {
        $nodes = $datum.AllNodes.$environment | Get-Member -MemberType ScriptProperty | Select-Object -ExpandProperty Name
        foreach ($node in $nodes)
        {
            $datum.AllNodes.$environment.$node
        }
    }
}

Describe "'LoadDatumConfigData' Tests" -Tags FunctionalQuality {

    BeforeEach {
        Remove-Variable -Name configurationData -Scope Global -ErrorAction SilentlyContinue
    }

    It "'LoadDatumConfigData' should fill the variable '`$global:configurationData' when using the right path" {

        $configDataDirectory = 'tests\Integration\Assets\ConfigData'
        Invoke-Build -File $BuiltModuleBase\Tasks\LoadDatumConfigData.build.ps1 -DatumConfigDataDirectory $configDataDirectory

        $configurationData | Should -Not -BeNullOrEmpty

    }

    It "'LoadDatumConfigData' should throw an error when using the wrong path" {

        $configDataDirectory = 'tests\Integration\Assets\WrongConfigData'
        { Invoke-Build -File $BuiltModuleBase\Tasks\LoadDatumConfigData.build.ps1 -DatumConfigDataDirectory $configDataDirectory } | Should -Throw

    }

    It "'LoadDatumConfigData' returns the right number of nodes" {

        $configDataDirectory = 'tests\Integration\Assets\ConfigData'
        Invoke-Build -File $BuiltModuleBase\Tasks\LoadDatumConfigData.build.ps1 -DatumConfigDataDirectory $configDataDirectory

        $configurationData.AllNodes.Count | Should -Be $allNodes.Count

    }

}
