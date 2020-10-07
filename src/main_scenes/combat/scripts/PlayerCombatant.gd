extends "res://main_scenes/combat/scripts/Combatant.gd"

func initialize(data):
	.initialize(data)

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


func get_targets(type):
	var targets = []
	
	if type == "Single Enemy" or type == "Single Ally":
		var target = get_node("../../UI").set_single_target(type)
		targets.append(target)
	else:
		match type:
			"Self":
				targets.append(self)
			"All Enemies":
				for combatant in get_parent().get_children():
					if combatant.is_in_group("Enemies"):
						targets.append(combatant)
			"All Allies":
				for combatant in get_parent().get_children():
					if combatant.is_in_group("Players"):
						targets.append(combatant)
	
	return targets
