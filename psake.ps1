task default -depends Test
task Test -precondition { $true }
{
  'Running the Test task here'
}
task Compile -depends Test 
{ 
  'Running the Compile task here'
  & .\build.ps1
}