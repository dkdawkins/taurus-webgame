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
	#Determine action from ability_data (Also look for basicAttack)
#	if not ability_data.has(actionName):
#		print("Error: ")
	
	#Select target if necessary
	#Apply action effects
	#End turn

	#FOR TESTING ONLY###################
	print(actionName)
	var actionDamage = attackPoints
	var targets = get_targets("Single Enemy")
	for target in targets:
		target.take_damage(actionDamage)
		emit_signal("action_performed", str(self.name + " attacked " + targets[0].name + "!"))
	emit_signal("turn_finished")
	####################################

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
