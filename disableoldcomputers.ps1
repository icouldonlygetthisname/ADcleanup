## Variables to set ##
# Variables for setting inactivity threshold
$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive))

# Path to output the get-computers list - change path for the correct domain on the DC
$path = 'C:\Users\administrator.DOMAIN\Documents\oldcomputers.txt'

#OU to move computers to 
$OU = 'OU=Disabled Computers,DC=domain,DC=local'

#Schedule Task Varibles 
$28dayslater = (Get-Date).Adddays(+(1))
$colonlessdate = $28dayslater | ForEach-Object { $_ -replace ":|/", "-" }

$action = New-ScheduledTaskAction -Execute 'Powershell.exe'`
-Argument '-ExecutionPolicy Unrestricted -WindowStyle Hidden -File C:\Users\administrator.DOMAIN\Documents\deleteoldcomputers.ps1'
$trigger =  New-ScheduledTaskTrigger -Once -At $28dayslater

$TaskName = "Delete old computers at $colonlessdate"
$Principal = New-ScheduledTaskPrincipal -Id 'Author' `
-UserId 'DOMAIN\administrator' `
-LogonType Password `
-RunLevel Highest
                                        
$Task = New-ScheduledTask -Description 'Delete old computers from OU Disabled Computers ' ` 
-Action $action `
-Principal $Principal `
-Trigger $Trigger

$SecurePassword = $password = Read-Host -AsSecureString
$user = 'DOMAIN\administrator'
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 



## End Variables ##

# list of computers to be dumped into text files with only the name no other attributes
Get-ADComputer -Filter 'lastlogontimestamp -lt $time' -Properties Name | Select-Object -ExpandProperty Name | Out-file -FilePath $path -Force

# Confirmation of list of computers on screen
$Computers = Get-Content $path

# Step to disable Computer accounts and move to OU

Foreach($computer in $Computers)
{
if ($computer.Trim()) 
{
Get-ADComputer $computer | Disable-ADAccount -PassThru | Move-ADObject -TargetPath $OU
}
}


# Set Schedule Task

$Task | Register-ScheduledTask -TaskName $TaskName  -User 'DOMAIN\administrator' -Password $Password
