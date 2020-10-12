extends "res://main_scenes/combat/scripts/Combatant.gd"

#const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")

var combatActions = []
var actionPatterns = []

func initialize(data):
	.initialize(data)
	for ability in data["abilities"]:
		combatActions.append(ability)
	for pattern in data["patterns"]:
		actionPatterns.append(pattern)

func set_active(isCombatantActive):
	active = isCombatantActive
	if not active:
		return
	
	#Wait for TurnQueue
	yield(get_tree().create_timer(0.5), "timeout")
	
	perform_action("attack")


func get_targets(type):
	var targets = []
	
	match type:
		"Self":
			targets.append(self)
		"Single Enemy":
			#TODO: randomize selected character
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players"):
					targets.append(combatant)
					break
		"All enemies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players"):
					targets.append(combatant)
		"Single Ally":
			#TODO: randomize selected character
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies"):
					targets.append(combatant)
					break
		"All allies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies"):
					targets.append(combatant)
	
	return targets
