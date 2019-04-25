function New-MDEC2Tag {
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
