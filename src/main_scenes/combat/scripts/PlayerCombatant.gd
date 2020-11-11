extends "res://main_scenes/combat/scripts/Combatant.gd"

var basicAttack = "strike"
var fleeAction = "flee"
var specialAbilities = []
var stances = []
var items = []

#signal queue_finished(pc_state, npc_state)

func initialize(combatant_stats, ability_dict):
	.initialize(combatant_stats, ability_dict)
	basicAttack = combatant_stats["basicAttack"]
	specialAbilities = combatant_stats["specialAbilities"]
	stances = combatant_stats["stances"]
	items = combatant_stats["items"]

func attack():
	self.perform_action(basicAttack)

func secondary(name):
	self.perform_action(name)
	
func item():
	#If item available
		#Use item
		#End turn
	#Else
		#Display "no item" message
	pass
	
func flee():
	self.perform_action(fleeAction)

func get_targets(type):
	var targets = []
	
	match type:
		"Self":
			targets.append(self)
		"Single Enemy":
			if lastSingleTarget != null:
				if lastSingleTarget.is_in_group("Enemies"):
					targets.append(lastSingleTarget)
					return targets
			#Defaults to first enemy target
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies") and combatant.state == combatant.State.ALIVE:
					targets.append(combatant)
					lastSingleTarget = combatant
					break
		"Single Ally":
			if lastSingleTarget != null:
				if lastSingleTarget.is_in_group("Players"):
					targets.append(lastSingleTarget)
					return targets
			#Defaults to first ally
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players") and combatant.state == combatant.State.ALIVE:
					targets.append(combatant)
					lastSingleTarget = combatant
					break
		"All Enemies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies") and combatant.state == State.ALIVE:
					targets.append(combatant)
		"All Allies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players") and combatant.state == State.ALIVE:
					targets.append(combatant)
	
	return targets
