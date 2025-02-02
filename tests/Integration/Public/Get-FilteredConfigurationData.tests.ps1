BeforeAll {

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

Describe "'Get-DscResourceProperty' Tests" -Tags FunctionalQuality {

    It "'Get-FilteredConfigurationData' returns data" {

        Get-FilteredConfigurationData -Datum $datum | Should -Not -BeNullOrEmpty

    }

    It "'Get-FilteredConfigurationData' should not throw an error" {

        { Get-FilteredConfigurationData -Datum $datum } | Should -Not -Throw

    }

    It "'Get-FilteredConfigurationData' gets the correct number of nodes when not using a filter" {

        $configurationData = Get-FilteredConfigurationData -Datum $datum
        $configurationData.AllNodes.Count | Should -Be $allNodes.Count

    }

    It "'Get-FilteredConfigurationData' gets the correct number of nodes when using a filter on the node's name" {

        $configurationData = Get-FilteredConfigurationData -Datum $datum -Filter { $_.Name -like 'DSCFile*' }
        $configurationData.AllNodes.Count | Should -Be 3

    }

    It "'Get-FilteredConfigurationData' gets the correct number of nodes when using a filter on the environment" {

        $configurationData = Get-FilteredConfigurationData -Datum $datum -Filter { $_.Environment -eq 'Dev' }
        $configurationData.AllNodes.Count | Should -Be 3

    }

    It "'Get-FilteredConfigurationData' gets no nodes if filtered on a non-existing environment" {

        $configurationData = Get-FilteredConfigurationData -Datum $datum -Filter { $_.Environment -eq 'DoesNotExist' } -ErrorAction SilentlyContinue
        $configurationData.AllNodes.Count | Should -Be 0

    }

    It "'Get-FilteredConfigurationData' with a filter on a non-existing environment should throw an error" {

        { Get-FilteredConfigurationData -Datum $datum -Filter { $_.Environment -eq 'DoesNotExist' } -ErrorAction Stop } | Should -Throw

    }

}
