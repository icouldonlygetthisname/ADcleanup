# ADcleanup
PowerShell Scripts for cleaning up AD 
The main purpose of these are to find stale AD objects and then move them to an OU then delete them with a schedule task. 

Stage 1 -- Run 1 scrtipt manually invokes moving all stale computer objects to an OU then runs another script a set ammount of days later to delete to computer objects. 
Stage 2 -- Automating steps in Stage 1 so it runs regularly. 

# Currnet work in progress 
Computer objects working successfully for Stage 1 
User objects needs a some work 

# To add
More things I'd like to add are some sort of logging for ISO27001 auditing, either into Event Viewer or being able to update an ITSM 
