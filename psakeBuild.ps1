task default -depends BuildModuleManifest, Analyse, Test

task BuildModuleManifest {
  exec { & $PSScriptRoot\buildModuleManifest.ps1 }
}

task Analyse {
  'Running analyzer'
  Invoke-ScriptAnalyzer -Path .\build.ps1 -Verbose
}

task Test -depends BuildModuleManifest {
  Invoke-Pester -Path $PSScriptRoot\Tests\Unit
}

task Compile {
  exec { & .\buildModuleManifest.ps1 }
}