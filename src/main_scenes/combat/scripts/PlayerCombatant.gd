extends "res://main_scenes/combat/scripts/Combatant.gd"

func initialize(hp):
	.initialize(hp)

func special(target):
	#Use special ability on target
	#End turn
	pass
	
func stance():
	#Open stance menu
	pass
	
func item():
	#If item available
		#Use item
		#End turn
	#Else
		#Display "no item" message
	pass
	
func flee():
	#Flee battle
	pass
