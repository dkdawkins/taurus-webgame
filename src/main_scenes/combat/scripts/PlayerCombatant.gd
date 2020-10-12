extends "res://main_scenes/combat/scripts/Combatant.gd"

var basicAttack = "strike"
var specialAbilities = []
var stances = []
var items = []

func initialize(combatant_stats, ability_dict):
	.initialize(combatant_stats, ability_dict)
	basicAttack = combatant_stats["basicAttack"]
	specialAbilities = combatant_stats["specialAbilities"]
	stances = combatant_stats["stances"]
	items = combatant_stats["items"]

func attack():
	self.perform_action(basicAttack)

func special():
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
					if combatant.is_in_group("Enemies") and combatant.state == State.ALIVE:
						targets.append(combatant)
			"All Allies":
				for combatant in get_parent().get_children():
					if combatant.is_in_group("Players") and combatant.state == State.ALIVE:
						targets.append(combatant)
	
	return targets
