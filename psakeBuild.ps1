task default -depends BuildModuleManifest, Analyse, Test

task BuildModuleManifest -depends Analyse, Test {
  'Building Module Manifest'
  exec { & $PSScriptRoot\buildModuleManifest.ps1 }
}

task Analyse {
  'Running analyzer'
  $saResults = Invoke-ScriptAnalyzer -Path .\PSMDTools\*.ps1
  if($saResults) {
    $saResults | Format-Table
    Write-Error -Message 'One or more Script Analyser errors/warnings were found' -ErrorAction Stop
  }
}

task Test {
  'Running Unit Tests'
  Invoke-Pester -Path $PSScriptRoot\Tests\Unit
}
