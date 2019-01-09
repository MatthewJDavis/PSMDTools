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

  
  Set-ClipboardText $response
}
