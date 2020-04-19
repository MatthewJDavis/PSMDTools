# Get the function from the Public directory and dot source it for testing against
$projectRoot = Resolve-Path "$PSScriptRoot\..\.."
$PublicRoot = Resolve-Path "$projectRoot\*\Public"
. $PublicRoot\Get-MDDirectorySize.ps1

Describe 'Get-DirectorySize' {
    It 'Throws an exception if a path is not found' {
        Mock Test-Path {
            $false
        }
        { Get-DirectorySize -Path 'c:\non-existant' } | Should -Throw  "The Path c:\non-existant does not exist"
    }
}