task default -depends BuildModuleManifest, Analyse, Test

task BuildModuleManifest {
  'Building Module Manifest'
  exec { & $PSScriptRoot\buildModuleManifest.ps1 }
}

task Analyse {
  'Running analyzer'
  Invoke-ScriptAnalyzer -Path .\build.ps1 -Verbose
}

task Test -depends BuildModuleManifest {
  'Running Unit Tests'
  Invoke-Pester -Path $PSScriptRoot\Tests\Unit
}

task Compile {
  'Compling Module Manifest'
  exec { & .\buildModuleManifest.ps1 }
}