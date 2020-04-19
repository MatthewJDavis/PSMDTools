# PSMDTools

PowerShell module with a number of helper tools for my day to day job.

## Building

Running a build will update the PSMDTools.psm1 module file in PSMDTools directory to add any new functions found in the private or public directories

The build script is a wrapper script for psakeBuild.ps1 and makes sure the prerequisites are installed and runs the specified tasks.

```powershell
# To build run
.\build.ps1

#To test run
.\build.ps1 -Task 'Test'
```

## Development

For development purposes, the path of the module can be added to the PowerShell session with the following code:

```powershell
$Env:PSModulePath += ';' + (Resolve-Path .)
```
