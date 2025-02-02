BeforeAll {

    Import-Module -Name datum -Force
    Import-Module -Name Sampler.DscPipeline -Force

    $datumPath = (Resolve-Path $ProjectPath\tests\Integration\Assets\ConfigData\Datum.yml).Path

    $datum = New-DatumStructure -DefinitionFile $datumPath
    $datum.AllNodes.Dev.DSCFile01 | Out-String | Write-Host
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

Describe "'CompileDatumRsop' Tests" -Tags FunctionalQuality {

    BeforeAll {
        $configDataDirectory = 'tests\Integration\Assets\ConfigData'
        Invoke-Build -File $BuiltModuleBase\Tasks\LoadDatumConfigData.build.ps1 -DatumConfigDataDirectory $configDataDirectory

        $rsopPath = Join-Path -Path $OutputDirectory -ChildPath RSOP
        Remove-Item -Path $rsopPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    AfterEach {

        $rsopPath = Join-Path -Path $OutputDirectory -ChildPath RSOP
        Remove-Item -Path $rsopPath -Recurse -Force -ErrorAction SilentlyContinue

    }

    It "'CompileDatumRsop' created same number of RSOP files as nodes in Datum" {

        Invoke-Build -File $BuiltModuleBase\Tasks\CompileDatumRsop.build.ps1 -Task CompileDatumRsop -DatumConfigDataDirectory $configDataDirectory

        $rsopPath = Join-Path -Path $OutputDirectory -ChildPath RSOP -AdditionalChildPath $ModuleVersion
        dir -Path $rsopPath | Should -HaveCount $allNodes.Count

    }

    It "'CompileDatumRsop' created same stores the RSOP files in the correct environment subfolder when UseEnvironment variable is set to '`$true'" {

        $UseEnvironment = $true
        Invoke-Build -File $BuiltModuleBase\Tasks\CompileDatumRsop.build.ps1 -Task CompileDatumRsop -DatumConfigDataDirectory $configDataDirectory

        foreach ($environment in $environments)
        {
            $rsopPath = Join-Path -Path $OutputDirectory -ChildPath RSOP -AdditionalChildPath $ModuleVersion, $environment
            $nodes = $allNodes | Where-Object Environment -EQ $environment
            dir -Path $rsopPath | Should -HaveCount $nodes.Count
        }

        Remove-Variable -Name UseEnvironment

    }

    It "'CompileDatumRsop' throws if UseEnvironment is used with a non-boolean value" {

        $UseEnvironment = 'somevalue'
        {
            Invoke-Build -File $BuiltModuleBase\Tasks\CompileDatumRsop.build.ps1 -Task CompileDatumRsop -DatumConfigDataDirectory $configDataDirectory
        } | Should -Throw

        Remove-Variable -Name UseEnvironment

    }

    It "'CompileDatumRsop' created same stores the RSOP files in the correct environment subfolder when UseEnvironment environment variable is set to '`$true'" {

        Set-ItResult -Skipped -Because 'This will be fixed in a future release'

        $env:UseEnvironment = $true
        Invoke-Build -File $BuiltModuleBase\Tasks\CompileDatumRsop.build.ps1 -Task CompileDatumRsop -DatumConfigDataDirectory $configDataDirectory

        foreach ($environment in $environments)
        {
            $rsopPath = Join-Path -Path $OutputDirectory -ChildPath RSOP -AdditionalChildPath $ModuleVersion, $environment
            $nodes = $allNodes | Where-Object Environment -EQ $environment
            dir -Path $rsopPath | Should -HaveCount $nodes.Count
        }

        Remove-Item -Path Env:\UseEnvironment

    }

    It "'CompileDatumRsop' created same stores the RSOP files in the correct environment subfolder when UseEnvironment environment variable is set to 'true'" {

        Set-ItResult -Skipped -Because 'This will be fixed in a future release'

        $env:UseEnvironment = 'True'
        Invoke-Build -File $BuiltModuleBase\Tasks\CompileDatumRsop.build.ps1 -Task CompileDatumRsop -DatumConfigDataDirectory $configDataDirectory

        foreach ($environment in $environments)
        {
            $rsopPath = Join-Path -Path $OutputDirectory -ChildPath RSOP -AdditionalChildPath $ModuleVersion, $environment
            $nodes = $allNodes | Where-Object Environment -EQ $environment
            dir -Path $rsopPath | Should -HaveCount $nodes.Count
        }

        Remove-Item -Path Env:\UseEnvironment

    }

    It "'CompileDatumRsop' throws if UseEnvironment is used with a non-boolean value" {

        $env:UseEnvironment = 'somevalue'
        {
            Invoke-Build -File $BuiltModuleBase\Tasks\CompileDatumRsop.build.ps1 -Task CompileDatumRsop -DatumConfigDataDirectory $configDataDirectory
        } | Should -Throw

        Remove-Item -Path Env:\UseEnvironment

    }

}
