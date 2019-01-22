# Prototype code

#Need to switch here for linux or windows
#Windows
$UserList = Get-Clipboard 



foreach($user in $userList){
  $adUser += "'" + $user.Replace(' ','.') + "',"
}
