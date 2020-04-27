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
        $RunRemote,
        [Parameter()]
        [pscredential]
        $Credentials
    )

    begin {

    }

    process {
        if ($PSBoundParameters['RunRemote']) {
            try {
                $CimSession = New-CimSession -Credential $Credentials -ComputerName $ComputerName -ErrorAction Stop
            } catch {
                Write-Error 'Unable to connect to computer'
            }

            $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession
            $comp = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $CimSession
            $procLoad = (Get-CimInstance -ClassName Win32_Processor -CimSession $CimSession).LoadPercentage
            $disk = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $CimSession
        } else {
            $environment = $env:OS
            switch ($environment) {
                'Windows_NT' {
                    $os = Get-CimInstance -ClassName Win32_OperatingSystem
                    $comp = Get-CimInstance -ClassName Win32_ComputerSystem
                    $procLoad = (Get-CimInstance -ClassName Win32_Processor).LoadPercentage
                    $disk = Get-CimInstance -ClassName Win32_LogicalDisk
                }
                Default {
                    'Environment not supported'
                    break
                }
            }
        }
        $system = [PSCustomObject][ordered]@{
            'ComputerName'         = $comp.Name
            'OS'                   = $os.Caption
            'Version'              = $os.Version
            'Build'                = $os.BuildNumber
            'LastBootTime'         = $os.LastBootUpTime
            'Manufacturer'         = $comp.Manufacturer
            'Model'                = $comp.Model
            'LogicalProcessors'    = $comp.NumberOfLogicalProcessors
            'RamGB'                = "$([math]::Round($comp.TotalPhysicalMemory / 1GB))"
            'DiskSize'             = "$([math]::Round($disk.Size / 1GB))"
            'DiskSpaceUsedPercent' = "$([math]::Round(($disk.Size - $disk.FreeSpace) * 100 / $disk.size))"
            'WindowsDir'           = $os.WindowsDirectory
            'ProcessorLoadPercent' = "$($procLoad)"
            'MemoryUsedPercent'    = "$([math]::Round(($os.TotalVisibleMemorySize -$os.FreePhysicalMemory) * 100 / $os.TotalVisibleMemorySize))"
            'FreeDiskSpaceGB'      = "$([math]::Round($disk.FreeSpace / 1GB))"
        }
        $system
    }
    end {
    }
}