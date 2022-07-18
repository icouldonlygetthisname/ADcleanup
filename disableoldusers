## Varibles to set ##
# Varibles for setting inactivity threshold
$DaysInactive = 365
$time = (Get-Date).Adddays(-($DaysInactive))

# Path to output the get-users list
$path3 = 'C:\Users\someuser\Documents\oldusers.txt'

#OU to move users to -- user the distingushed name rename as appropriate for your own setup 
$OU = 'OU=Disabled Users,DC=domain,DC=local' 

#Schedule Task Varibles 
$28dayslater = (Get-Date).Adddays(+(28))
$colonlessdate = $28dayslater | ForEach-Object { $_ -replace ":|/", "-" }
$action = New-ScheduledTaskAction -Execute 'Powershell.exe'`
-Argument '-ExecutionPolicy Unrestricted -WindowStyle Hidden -File C:\Users\someuser\Documents\deleteoldusers.ps1'
$trigger =  New-ScheduledTaskTrigger -Once -At $28dayslater
# $Description = "Delete old users from $OU at $colonlessdate" doesn't like varibles in the string 
$TaskName = "Delete old users at $colonlessdate"
$Principal = New-ScheduledTaskPrincipal -Id 'Author' `
-UserId 'Domain\administrator' `
-LogonType Password `
-RunLevel Highest
 
$Task = New-ScheduledTask -Description 'Delete old users from Disable Users OU' ` 
-Action $action `
-Principal $Principal `
-Trigger $Trigger

$SecurePassword = $password = Read-Host -AsSecureString
$adminuser = 'Domain\administrator'
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $adminuser, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 

## End Varibles ##

# list of users to be dumped into text files with only the name no other attributes modify the Searchbase to match your requirements
Get-ADuser -Filter 'lastlogontimestamp -lt $time' `
-SearchBase 'CN=Users,DC=domain,DC=local' `
-Properties SamAccountName `
| Select-Object -ExpandProperty SamAccountName | Out-file -FilePath $path3 -Force

# Confirmation of list of users on screen
$Users = Get-Content $path3
echo $Users

# pausing script just so you can confirm correct users are being disable, adjust time if needed
Start-Sleep -Seconds 90

# Step to disable user accounts and move to OU

Foreach($user in $Users)
{
Get-ADuser $user | Disable-ADAccount -PassThru | Move-ADObject -TargetPath $OU
}


# Set Schedule Task user the name admin account from above 

$Task | Register-ScheduledTask -TaskName $TaskName  -User 'Domain\administrator' -Password $Password
