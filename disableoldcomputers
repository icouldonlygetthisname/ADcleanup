## Varibles to set ##
# Varibles for setting inactivity threshold
$DaysInactive = 60
$time = (Get-Date).Adddays(-($DaysInactive))

# Path to output the get-computers list
$path1 = 'C:\Users\someuser\Documents\oldcomputers.txt'

#OU to move computers to 
$OU = 'OU=Disabled Computers,DC=domain,DC=local'

#Schedule Task Varibles 
$28dayslater = (Get-Date).Adddays(+(28))
$colonlessdate = $28dayslater | ForEach-Object { $_ -replace ":|/", "-" }
$action = New-ScheduledTaskAction -Execute 'Powershell.exe'`
-Argument '-ExecutionPolicy Unrestricted -WindowStyle Hidden -File C:\Users\someuser\Documents\deleteoldcomputers.ps1'
$trigger =  New-ScheduledTaskTrigger -Once -At $28dayslater
# $Description = "Delete old computers from $OU at $colonlessdate" doesn't like varibles in the string 
$TaskName = "Delete old computers at $colonlessdate"
$Principal = New-ScheduledTaskPrincipal -Id 'Author' `
-UserId 'domain\administrator' `
-LogonType Password `
-RunLevel Highest
                                        
$Task = New-ScheduledTask -Description '$Descritpion' ` #--- needs to be a string doesn't accept varible 
-Action $action `
-Principal $Principal `
-Trigger $Trigger

$SecurePassword = $password = Read-Host -AsSecureString
$user = 'Domain\administrator'
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $SecurePassword
$Password = $Credentials.GetNetworkCredential().Password 

## End Varibles ##

# list of computers to be dumped into text files with only the name no other attributes
Get-ADComputer -Filter 'lastlogontimestamp -lt $time' -Properties Name | Select-Object -ExpandProperty Name | Out-file -FilePath $path1 -Force

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

$Task | Register-ScheduledTask -TaskName $TaskName  -User 'domain\administrator' -Password $Password
