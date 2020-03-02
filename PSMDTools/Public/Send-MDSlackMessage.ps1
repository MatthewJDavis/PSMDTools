<#
.SYNOPSIS
    Sends a message to slack
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
function Send-MDSlackMessage {
    [CmdletBinding()]
    param (
        # URI of Slack Hook
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Uri,
        # Message To Send
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Message
    )

    begin {
        $payload = @{
            "text" = $Message
        }
    }

    process {
        Invoke-RestMethod -Method Post -Uri $Uri -Body (ConvertTo-Json -InputObject $payload -Compress) -UseBasicParsing | Out-Null
    }

    end {

    }
}