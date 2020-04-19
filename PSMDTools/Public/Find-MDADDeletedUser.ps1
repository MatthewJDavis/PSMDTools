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
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true )]
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
        $userList = Get-ADObject -SearchBase $deletedObjectContainer -IncludeDeletedObjects -filter "sAMAccountName -like '*$UserName*'" -Properties userPrincipalName, sAMAccountName |
        Select-Object userPrincipalName, sAMAccountName
        Write-Output $userList
    }

    end {
        remove-variable deletedObjectContainer
    }
}
