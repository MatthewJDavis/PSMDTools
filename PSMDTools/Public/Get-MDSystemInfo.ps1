<#
.SYNOPSIS
    Gets basic information about a computer system
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Get-MDSystemInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ComputerName = 'localhost',
        [Parameter()]
        [switch]
        $RunRemote
    )

    begin {
    }

    process {
        $environment = $env:OS
        switch ($environment) {
            'Windows_NT' {
                $os = Get-CimInstance -ClassName Win32_OperatingSystem
                $comp = Get-CimInstance -ClassName Win32_ComputerSystem
            }
            Default {
                'Environment not yet supported'
                break
            }
        }

        $system = [PSCustomObject][ordered]@{
            'OS'                = $os.Caption
            'Version'           = $os.Version
            'Build'             = $os.BuildNumber
            'LastBootTime'      = $os.LastBootUpTime
            'ComputerName'      = $comp.Name
            'Manufacturer'      = $comp.Manufacturer
            'Model'             = $comp.Model
            'LogicalProcessors' = $comp.NumberOfLogicalProcessors
            'Ram'               = "$([math]::Round($comp.TotalPhysicalMemory / 1GB))GB"
            'WindowsDir'        = $os.WindowsDirectory
        }
        $system
    }

    end {
    }
}