## Variables to set ##

# Path to output the get-users list
$path4 = 'C:\Users\administrator.DOMAIN\Documents\deleteusers.txt'

# Date for last modified on Objects in OU to delete
$date = (Get-Date).Adddays(-(7))

# OU to delete users from
$OU = "OU=Disabled Users,DC=domain,DC=local"

## End Variables ##

# Get list of users in OU and pipe to a file based off modified date
Get-ADuser -Filter 'Modified -le $date' -SearchBase "$OU" -Properties SamAccountName | Select-Object -ExpandProperty SamAccountName | Out-file -FilePath $path4 -Force

# Delete user objects
$users = Get-Content $path4
Foreach($user in $users)
{
 
      $userGUID = (Get-ADuser -Identity $user).ObjectGUID
      Remove-ADObject -identity "$userGUID" -Confirm:$false 
      
    }

