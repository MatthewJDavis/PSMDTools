function New-MDEncryptedPasswordFile {
  [CmdletBinding()]
  param (
    # Path of where to save the Key and Password files
    [Parameter(mandatory=$true)]
    [String]
    $Path,
    # Password to encrypt
    [Parameter(mandatory=$true)]
    [String]
    $Password
  )
  
  begin {
    $keyFile = Join-Path -Path $Path -ChildPath 'aes.key'
    $passwordFile = Join-Path $Path -ChildPath 'password.txt'
  }
  
  process {
    try {
      $Key = New-Object Byte[] 32
      [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
      $Key | out-file  $keyFile
    }
    catch {
      
    }

    try {
      $Password | set-content $passwordFile
    }
    catch {
      
    }
  }
  
  end {
  }
}
