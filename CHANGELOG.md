# Changelog for Sampler.DscPipeline

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Adding pipeline tasks and commands from DSC Workshop.
- Small changes to support easier deployment for individual environments.
- Added scripts for compiling MOF and Meta MOF files without the need for the `rootConfig.ps1` script. It is now a self-contained task that takes parameters from the `Build.yml`.
- Having modules available more than once results in: ImportCimAndScriptKeywordsFromModule : "A second CIM class definition
  for 'MSFT_PSRepository' was found while processing the schema file". Fixed that by using function 'Get-DscResourceFromModuleInFolder'.
  This usually happens with 'PackageManagement' and 'PowerShellGet'
