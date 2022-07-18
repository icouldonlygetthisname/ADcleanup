## Varibles to set ##

# Path to output the get-computers list
$path2 = 'C:\Users\someuser\Documents\deletecomputers.txt'

# Date for last modified on Objects in OU to delete
$date = (Get-Date).Adddays(-(1))

# OU to delete computers from
$OU = "OU=Disabled Computers,DC=domain,DC=local"

## End Varibles ##

# Get list of computers in OU and pipe to a file based of modified date
Get-ADComputer -Filter 'Modified -le $date' -SearchBase "$OU" -Properties Name | Select-Object -ExpandProperty Name | Out-file -FilePath $path2 -Force

# Delete computer objects
$Computer = Get-Content $path2
Foreach($computers in $Computer)
{
 
      $ComputerGUID = (Get-ADComputer -Identity $Computers).ObjectGUID
      Remove-ADObject -identity $ComputerGUID -Confirm:$false -Recursive 
      
    }

