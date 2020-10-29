extends "res://main_scenes/combat/scripts/Combatant.gd"

var basicAttack = "strike"
var fleeAction = "flee"
var specialAbilities = []
var stances = []
var items = []

signal queue_finished(pc_state, npc_state)

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
			if lastTarget != null:
				if lastTarget.is_in_group("Enemies"):
					targets.append(lastTarget)
					return targets
			var target = get_node("../../UI").set_single_enemy_target()
			targets.append(target)
			lastTarget = target
		"Single Ally":
			if lastTarget != null:
				if lastTarget.is_in_group("Players"):
					targets.append(lastTarget)
					return targets
			var target = get_node("../../UI").set_single_ally_target()
			targets.append(target)
			lastTarget = target
		"All Enemies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Enemies") and combatant.state == State.ALIVE:
					targets.append(combatant)
		"All Allies":
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players") and combatant.state == State.ALIVE:
					targets.append(combatant)
	
	return targets
