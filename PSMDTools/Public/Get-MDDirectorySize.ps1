<#
.DESCRIPTION
Displays the amount of bytes used by a given directory
.EXAMPLE
Get-DirectorySize -Path 'C:\Program Files'
#>
function Get-DirectorySize {
    [CmdletBinding()]
    # Path of the directory to find the size of the subdirectories
    param(
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    begin {
    }

    process {
        if (-not (Test-Path -LiteralPath $Path)) {
            Throw "The Path $Path does not exist"
        }
        Get-ChildItem -Path $Path -Recurse -Force | Measure-Object -Property Length -Sum | Select-Object Count, Sum
    }
    end {
    }

}