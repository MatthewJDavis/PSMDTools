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
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [string]
        $DistinguishedName
    )

    begin {
        if (-not (Select-String -InputObject $DistinguishedName -Pattern 'OU' -CaseSensitive -Quiet)) {
            Write-Output 'OU not found in input string'
            Break
        }
    }

    process {
        $ouIndex = $DistinguishedName.IndexOf('OU')
        $ouPath = $DistinguishedName.Remove(0, $ouIndex)
        Write-Output -InputObject $ouPath
    }

    end {
    }
}