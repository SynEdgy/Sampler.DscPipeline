# Changelog for Sampler.DscPipeline

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Updated build scripts to latest Sampler version.
- Integration tests for 'LoadDatumConfigData' task.
- Integration tests for 'CompileDatumRsop' task.
- Integration tests for 'Get-DscResourceProperty' function.
- Added error handling and debug output for 'LoadDatumConfigData'.

### Fixed

- Fix parsing of UseEnvironment parameter in CompileDatumRsop task ([#39](https://github.com/SynEdgy/Sampler.DscPipeline/issues/39))

## [0.2.0] - 2024-11-09

### Added

- Adding pipeline tasks and commands from DSC Workshop.
- Small changes to support easier deployment for individual environments.
- Added scripts for compiling MOF and Meta MOF files without the need for the `rootConfig.ps1` script. It is now a self-contained task that takes parameters from the `Build.yml`.
- Having modules available more than once results in: ImportCimAndScriptKeywordsFromModule : "A second CIM class definition
  for 'MSFT_PSRepository' was found while processing the schema file". Fixed that by using function 'Get-DscResourceFromModuleInFolder'.
  This usually happens with 'PackageManagement' and 'PowerShellGet'
- The handling of the DSC MOF compilation has changed. The file 'RootConfiguration.ps1' is still used when present in the source of
  the DSC project that uses 'Sampler.DscPipeline'. Same applies to the Meta MOF compilation script 'RootMetaMof.ps1'. If these
  files don't exist, 'Sampler.DscPipeline' uses the scripts in 'ModuleRoot\Scripts'. To control which DSC composite and resource modules should be imported within the DSC configuration, add the section 'Sampler.DscPipeline' to the 'build.yml' as described
  on top of the file 'CompileRootConfiguration.ps1'.
- Added error handling discovering 'CompileRootConfiguration.ps1' and 'RootMetaMof.ps1'
- Test cases updated to Pester 5.
- Fixing issue with ZipFile class not being present.
- Fixing calculation of checksum if attribute NodeName is different to attribute Name (of YAML file).
- Increase build speed of root configuration by only importing required Composites/Resources.
- Added ''UseEnvironment'' parameter to cater for RSOP for identical node names in different environments.
- Adding Home.md to wikiSource and correct casing.
- Removed PSModulePath manipulation from task `CompileRootConfiguration.build.ps1`. This is now handled by the Sampler task `Set_PSModulePath`.
- Redesign of the function Split-Array. Most of the time it was not working as expected, especially when requesting larger ChunkCounts (see AutomatedLab/AutomatedLab.Common/#118)
- Redesign of the function Split-Array. Most of the time it was not working as expected, especially when requesting larger ChunkCounts (see AutomatedLab/AutomatedLab.Common/#118).
- Improved error handling when compiling MOF files and when calling 'Get-DscResource'.
- Redesign of the function 'Split-Array'. Most of the time it was not working as expected, especially when requesting larger ChunkCounts (see AutomatedLab/AutomatedLab.Common/#118).
- Improved error handling when compiling MOF files.
- Removed name check when creating Meta MOF files.
- Update GitVersion.Tool installation to use version 5.*

### Fixed

- Fixed regex for commit message `--Added new node`
- Fixed task `Compress_Artifact_Collections` fails when node is filtered
