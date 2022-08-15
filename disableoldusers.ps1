## Variables to set ##
# Variables for setting inactivity threshold
$DaysInactive = 365
$time = (Get-Date).Adddays(-($DaysInactive))

# Path to output the get-users list
$path3 = 'C:\Users\administrator.DOMAIN\Documents\oldusers.txt'

#OU to move users to 
$OU = 'OU=Disabled Users,DC=domain,DC=local'

#Schedule Task Variables 
$28dayslater = (Get-Date).Adddays(+(28))
$colonlessdate = $28dayslater | ForEach-Object { $_ -replace ":|/", "-" }
$action = New-ScheduledTaskAction -Execute 'Powershell.exe'`
-Argument '-ExecutionPolicy Unrestricted -WindowStyle Hidden -File C:\Users\administrator.DOMAIN\Documents\deleteoldusers.ps1'
$trigger =  New-ScheduledTaskTrigger -Once -At $28dayslater
$TaskName = "Delete old users at $colonlessdate"
$Principal = New-ScheduledTaskPrincipal -Id 'Author' `
-UserId 'DOAMIN\administrator' `
-LogonType Password `
-RunLevel Highest
                                        
$Task = New-ScheduledTask -Description 'Delete old users from OU Disabled Users' `  
-Action $action `
-Principal $Principal `
-Trigger $Trigger

$SecurePassword = $password = Read-Host -AsSecureString
$user = 'DOMAIN\administrator'
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 



## End Variables ##

# list of users to be dumped into text files with only the name no other attributes
Get-ADuser -Filter * `
-SearchBase 'CN=Users,DC=domain,DC=local' `
-Properties SamAccountName, lastlogontimestamp `
| where-object {(([DateTime]::FromFileTime($_.lastlogontimestamp) -lt $time) -or (($_.lastlogontimestamp) -eq $null)) -AND ($_.SamAccountName -notmatch "krbtgt|guest")} `
| Select-Object -ExpandProperty SamAccountName | Out-file -FilePath $path3 -Force

# Confirmation of list of users on screen
$Users = Get-Content $path3

# Step to disable user accounts and move to OU

Foreach($user in $Users)
{
Get-ADuser $user | Disable-ADAccount -PassThru | Move-ADObject -TargetPath $OU
}



# Set Schedule Task

$Task | Register-ScheduledTask -TaskName $TaskName  -User 'DOAMIN\administrator' -Password $Password
