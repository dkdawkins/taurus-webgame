extends Node2D

enum State {ALIVE, DEAD}

#declare default combatant stats here
var hitPoints = 1
var maxHitPoints = 1
var attackPoints = 1
var defensePoints = 1

var ability_data
var active = false setget set_active
var state = State.ALIVE setget set_state

signal action_performed(actionDialog)
signal turn_finished
#signal dead
signal hitPoints_changed
signal state_changed

func initialize(combatant_stats, ability_dict):
	ability_data = ability_dict
	hitPoints = combatant_stats["hp"]
	maxHitPoints = combatant_stats["hp"]
	attackPoints = combatant_stats["ap"]
	defensePoints = combatant_stats["dp"]
	self.set_name(combatant_stats["name"])

func set_active(isCombatantActive):
	active = isCombatantActive

func set_state(combatantState):
	state = combatantState
	emit_signal("state_changed")

func perform_action(actionName):
	var action = ability_data[actionName]
	#TODO: display action animation
	for effect in action["effects"]:
		match effect["type"]:
			"Damage":
				apply_damage_effect(effect)
			"Heal":
				apply_heal_effect(effect)
			"Status":
				apply_status_effect(effect)
			"Buff":
				apply_buff_effect(effect)
	print(str(self.name + " used " + actionName))	#FOR TESTING ONLY
	emit_signal("turn_finished")

func apply_damage_effect(effect):
	var actionDamage = attackPoints * (effect["modifier"] / 50) #TODO: improve damage calculation
	var targets = get_targets(effect["target"])
	for n in range(effect["numHits"]):
		for target in targets:
			target.take_damage(actionDamage)

func apply_heal_effect(effect):
	pass

func apply_status_effect(effect):
	pass

func apply_buff_effect(effect):
	pass

func take_damage(damage):
	var actualDamage = damage - defensePoints
	if actualDamage < 0:
		actualDamage = 0
	hitPoints -= actualDamage
	
	#TODO: Play animations/sounds
	
	#Signal UI to update
	if actualDamage > 0:
		emit_signal("hitPoints_changed")
	#Signal if dead
	if hitPoints <= 0:
		self.state = State.DEAD


func get_targets(type):
	print("Base get_target function called; this should not happen")
	pass
