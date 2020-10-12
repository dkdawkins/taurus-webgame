extends "res://main_scenes/combat/scripts/Combatant.gd"

#const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")

var combatActions = []
var actionPatterns = []
var currPattern = -1
var currPatternStep = -1

func initialize(combatant_stats, ability_dict):
	.initialize(combatant_stats, ability_dict)
	for ability in combatant_stats["abilities"]:
		combatActions.append(ability)
	for pattern in combatant_stats["patterns"]:
		actionPatterns.append(pattern)

func set_active(isCombatantActive):
	.set_active(isCombatantActive)
	if not active:
		return
	
	var actionToPerform
	
	#Wait for TurnQueue
	yield(get_tree().create_timer(0.5), "timeout")
	
	if actionPatterns.empty():
		actionToPerform = combatActions[randi() % combatActions.size()]
	else:
		#If not currently in a pattern, select a random one to start
		if currPattern == -1:
			currPattern = randi() % actionPatterns.size()
			currPatternStep = 0
		actionToPerform = actionPatterns[currPattern][currPatternStep]
		#Increment index if pattern is unfinished; reset otherwise
		if (currPatternStep + 1) >= actionPatterns[currPattern].size():
			currPattern = -1
			currPatternStep = -1
		else:
			currPatternStep += 1
	perform_action(actionToPerform)


func get_targets(type):
	var targets = []
	
	match type:
		"Self":
			targets.append(self)
		"Single Enemy":
			#TODO: randomize selected character
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players") and combatant.state == State.ALIVE:
					targets.append(combatant)
					break
		"All enemies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players") and combatant.state == State.ALIVE:
					targets.append(combatant)
		"Single Ally":
			#TODO: randomize selected character
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies") and combatant.state == State.ALIVE:
					targets.append(combatant)
					break
		"All allies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies") and combatant.state == State.ALIVE:
					targets.append(combatant)
	
	return targets
