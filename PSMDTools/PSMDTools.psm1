<#
.SYNOPSIS
  Finds a deleted Active Directory User
.DESCRIPTION
  Find a deleted Active Directory user in the Active Directory recycle bin.
  The Active Directory Recycle Bin needs to be enabled: https://activedirectorypro.com/enable-active-directory-recycle-bin-server-2016/
.EXAMPLE
  PS C:\> Find-MDADDeletedUser -UserName test
  This command searches the Active Directory recycle bin for users that sAMAccountName contains the word test anywhere.
#>
function Find-MDADDeletedUser {
  [CmdletBinding()]
  param (
    # The full or part username of the deleted user
    [Parameter(
      Mandatory = $true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true )]
    [string]
    $UserName
  )
  
  begin {
    # Make sure Active Directory Recycle Bin is Enabled
    if ($null -eq (Get-ADOptionalFeature -filter *).EnabledScopes) {
      Write-Error 'Acitve Directory Recycle Bin is not Enabled' -ErrorAction Stop
    }
    
    $deletedObjectContainer = (get-addomain).DeletedObjectsContainer    
  }
  
  process {
    $userList = Get-ADObject -SearchBase $deletedObjectContainer -IncludeDeletedObjects -filter "sAMAccountName -like '*$UserName*'" -Properties userPrincipalName, sAMAccountName  |
      Select-Object userPrincipalName, sAMAccountName
    Write-Output $userList
  }
  
  end {
    remove-variable deletedObjectContainer
  }
}
<#
.SYNOPSIS
  Outputs the OU path after removal of the Distinguished Name
.DESCRIPTION
  Get a distigguished name property from an Active Directory cmdlet i.e Get-ADUser, Get-ADComputer and this function will return the OU
  of the object which can be used if you want to create or move other objects to that OU
.EXAMPLE
  (Get-ADUser -Identity Keith.Moon).DistinguishedName | Get-ADOuFromDN
.EXAMPLE
  (Get-ADComputer dc01).DistinguishedName | Get-ADOuFromDN
#>
function Get-MDADOUFromDN {
  [CmdletBinding()]
  param (
    # The string with the distinguished name from an AD cmdlet output
    [Parameter(Mandatory=$true,
    Position=0,
    ValueFromPipeline=$true)]
    [string]
    $DistinguishedName
  )
  
  begin {
    if(-not (Select-String -InputObject $DistinguishedName -Pattern 'OU' -CaseSensitive -Quiet)){
      Write-Host 'OU not found in input string'
      Break   
    }
  }
  
  process {
    $ouIndex = $DistinguishedName.IndexOf('OU')
    $ouPath = $DistinguishedName.Remove(0,$ouIndex)
    Write-Output -InputObject $ouPath
  }
  
  end {
  }
}
# Prototype code

#Need to switch here for linux or windows
#Windows
$UserList = Get-Clipboard 



foreach($user in $userList){
  $adUser += "'" + $user.Replace(' ','.') + "',"
}
<#
.SYNOPSIS
  Create a tag for AWS Ec2 instance
.DESCRIPTION
  Creates a key value pair for tagging an EC2 instance
.EXAMPLE
  PS C:\> New-MDEC2Tag -Key 'Name' -Value 'server-01'
  Creates an EC2 tag with the key of Name and Value of server-01
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
function New-MDEC2Tag {
  [CmdletBinding()]
  param (
    # Tag Key
    [Parameter(Mandatory = $true)]
    [string]
    $Key,
    # Tag Value
    [Parameter(Mandatory = $true)]
    [string]
    $Value
  )
  
  begin {
    # This flag allows us to abort the actual execution of the script if any of
    # the checks in the Begin block fail.
    $Script:AbortFromBegin = $false

    # Import the AWS PowerShell module. Stop if unsuccessful, since we won't be
    # able to do anything useful without it. Also, we are forcing Verbose to
    # false to prevent tons of output when the caller wants verbose output from
    # the script.
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
      Import-Module -Name AWSPowerShell -Verbose:$false -ErrorAction Stop
    }
    elseif ($PSVersionTable.PSEdition -eq 'Core') {
      Import-Module -Name AWSPowerShell.NetCore -Verbose:$false -ErrorAction Stop
    }
    

    # If the caller gave us a profile name to use, set that up.
    if ($PSBoundParameters.ContainsKey("ProfileName")) {
      # There might be a session profile set already. Store it so we can put
      # it back later.
      $Script:PreviousSessionCredential = Get-AWSCredential

      # Now set a session default credential to use for our script.
      Write-Verbose -Message "Setting session default profile to '$ProfileName'."
      Set-AWSCredential -ProfileName $ProfileName

      # The special variable $? will contain true if the previous command was
      # successful, otherwise false. If we failed to set the session profile,
      # abort the script.
      $Script:AbortFromBegin = $Script:AbortFromBegin -or !$?
    }
    
    # If the caller gave us a region to use, set that up.
    if ($PSBoundParameters.ContainsKey("Region")) {
      # There might be a session default region set already. Store it so we
      # can put it back later.
      $Script:PreviousDefaultRegion = Get-DefaultAWSRegion

      # Now set a session default region to use for our script.
      Write-Verbose -Message "Setting session default region to '$Region'."
      Set-DefaultAWSRegion -Region $Region

      # Again using $? to test if the previous command worked, and aborting
      # if it didn't.
      $Script:AbortFromBegin = $Script:AbortFromBegin -or !$?
    }  
  }
  
  process {
    $script:tag = New-Object -TypeName Amazon.EC2.Model.Tag
    $script:tag.Key = $key 
    $script:tag.Value = $value
  
    return $script:tag
  }
  
  end {
    # If the caller passed in a profile name, we need to reset the session's
    # default profile to whatever it was.
    if ($PSBoundParameters.ContainsKey("ProfileName")) {
      if ($Script:PreviousSessionCredential) {
        # This session had a default profile set. Put it back.
        Write-Verbose -Message "Restoring previous session default profile."
        Set-AWSCredential -Credential $Script:PreviousSessionCredential
      }
      else {
        # This session had no default profile set. Clear the profile we just
        # used for this script.
        Write-Verbose -Message "Clearing session default profile."
        Clear-AWSCredential
      }
    }

    # If the caller passed in a default region, we need to reset the session's
    # default region to whatever it was.
    if ($PSBoundParameters.ContainsKey("Region")) {
      if ($Script:PreviousDefaultRegion) {
        # This session had a default region set. Put it back.
        Write-Verbose -Message "Restoring previous session default region."
        Set-DefaultAWSRegion -Region $Script:PreviousDefaultRegion
      }
      else {
        # This session had no default region set. Clear the region we just
        # used for this script.
        Write-Verbose -Message "Clearing session default region."
        Clear-DefaultAWSRegion
      }
    }
  }
}
function New-MDEncryptedPasswordFile {
  [CmdletBinding()]
  param (
    # Path of where to save the Key and Password files
    [Parameter(mandatory = $true)]
    [String]
    $Path,
    # Password to encrypt
    [Parameter(mandatory = $true)]
    [SecureString]
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
    } catch {
      
    }

    try {
      $Password | ConvertFrom-SecureString -key (Get-Content $keyFile) | Set-Content $passwordFile
    } catch {
      
    }
  }
  
  end {
  }
}
<#
.SYNOPSIS
  Restore an Active Directory User from the AD recycle bin by sAMAccountName.
.DESCRIPTION
  Restore an Active Directory User from the AD recycle bin by sAMAccountName. Restores User to previous location in AD.
  Active Directory Recycle Bin needs to be enabled: https://activedirectorypro.com/enable-active-directory-recycle-bin-server-2016/
.EXAMPLE
  PS C:\> Restore-MDADUser test.mctest
  
  Restores the user test.mctest back to Active Directory.
.NOTES
  Taken from:
  https://blogs.technet.microsoft.com/canitpro/2016/05/18/powershell-basics-restoring-a-deleted-powershell-user/
#>

function Restore-MDADUser {
  [CmdletBinding()]
  param (
    # The samAccountName of the deleted user
    [Parameter(
      Mandatory = $true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true )]
    [string]
    $sAMAccountName
  )

  begin {
    # Make sure Active Directory Recycle Bin is Enabled
    if ($null -eq (Get-ADOptionalFeature -filter *).EnabledScopes) {
      Write-Error 'Acitve Directory Recycle Bin is not Enabled' -ErrorAction Stop
    }
    
    $deletedObjectContainer = (get-addomain).DeletedObjectsContainer
  }
  
  process {
    $distinguishedName = (Get-ADObject -SearchBase $deletedObjectContainer -IncludeDeletedObjects -filter "sAMAccountName -eq '$sAMAccountName'").distinguishedname
    if ($null -eq $distinguishedName) {
      Write-Error "sAMAccountName $sAMAccountName is not found in the Active directory recyle bin." -ErrorAction Stop
    }
    else {
      try {
        Restore-ADObject -Identity $distinguishedName -ErrorAction Stop
        $message = "User $sAMAccountName has been restored. `n"
        $message += (Get-ADUser -Identity $sAMAccountName).DistinguishedName
      }
      catch {
        Write-Error -Message "Unable to restore $sAMAccount to Active Directory `n $PSItem"
      }
    }


    Return $message
  } # end process
  
  end {
    Remove-Variable deletedObjectContainer
  }
}
function Set-MDStandardResponse {
  param (
    # Parameter help description
    [Parameter(Mandatory = $false)]
    [String]
    $Name,
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    [ValidateSet('aws','adgroupadd', 'approval')]
    $ResponseType 
  )

  switch ($ResponseType) {
    'aws' { $response = "Hello $Name, `r`rYour account has been added to the requested AWS group(s). It can take 15 mins for the changes to propagate and you may need to logout and back into AWS Central access. `r`rThanks `r`rMatt" }
    'adgroupadd' {$response = "Hello , `r`rAD account added to requested group.`r`rThanks,`r`rMatt"}
    'approval' {$response = "Hello , `r`rCould you please approve the request for access to the production AWS accounts?`r`rThanks,`r`rMatt"}
    Default {}
  }

  # Set the clipboard to the response
  if ($PSVersionTable.PSEdition -eq 'Desktop') {
    Set-Clipboard -Value $response
  } elseif ($PSVesionTable.PSEdition -eq 'Core') {
    if ((Get-Module -Name ClipboardText -ListAvailable) -eq $true) {
      Import-Module -Name ClipboardText
      Set-ClipboardText $response
    } else {
      Write-Error 'ClipboardText module not found. Please install it from the PowerShell gallery by running Install-Module -Name ClipboardText' -ErrorAction Stop
    }
  }
}
Export-ModuleMember -Function 
