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
