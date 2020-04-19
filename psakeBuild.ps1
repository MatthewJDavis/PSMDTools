task default -depends BuildModuleManifest, Analyse, Test

task BuildModuleManifest -depends Analyse, Test {
  'Building Module Manifest'
  exec { & $PSScriptRoot\buildModuleManifest.ps1 }
}

task Analyse {
  'Running analyzer'
  Invoke-ScriptAnalyzer -Path .\build.ps1 -Verbose
}

task Test {
  'Running Unit Tests'
  Invoke-Pester -Path $PSScriptRoot\Tests\Unit
}
