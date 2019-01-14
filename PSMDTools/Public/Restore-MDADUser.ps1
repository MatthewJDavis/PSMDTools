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
      }
      catch {
        Write-Error -Message "Unable to restore $sAMAccount to Active Directory"
      }
    }

    $message = "User $sAMAccountName has been restored: `n"
    $message += (Get-ADUser -Identity $sAMAccountName).DistinguishedName
    Return $message
  } # end process
  
  end {
    Remove-Variable deletedObjectContainer
  }
}
