# Get the function from the Public directory and dot source it for testing against
$projectRoot = Resolve-Path "$PSScriptRoot\..\.."
$PublicRoot = Resolve-Path "$projectRoot\*\Public"
. $PublicRoot\New-MDEncryptedPasswordFile.ps1


Describe 'New-MDEncryptedPasswordFile' {
  $pass = ConvertTo-SecureString -String "Monkey1234" -AsPlainText -Force
  Context 'File tests' {
    New-MDEncryptedPasswordFile -Path $TestDrive -Password $pass
    It "Creates the password.txt file in $TestDrive\Password file" {
      Test-Path -Path $TestDrive\password.txt | should be $true
    }
    It "Creates the aes.key file in the test drive location" {
      Test-Path -Path $TestDrive\aes.key | should be $true
    }
  }

}