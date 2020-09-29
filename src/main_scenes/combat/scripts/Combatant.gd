extends Node2D

#declare default combatant stats here
var hitPoints = 1
var maxHitPoints = 1
var attackPoints = 2
var defensePoints = 1

var active = false setget set_active

signal action_performed(actionDialog)
signal turn_finished
signal dead
signal hitPoints_changed

func initialize(hp):
	#initialize stats
	#TODO: get stats from given combatant data
	hitPoints = hp
	maxHitPoints = hp

func set_active(isCombatantActive):
	active = isCombatantActive

func perform_action(actionName, target):
	#TODO: pull action data dynamically from a resource
	var actionDamage = attackPoints
	#TODO: implement other combat actions
	if actionName == "attack":
		target.take_damage(actionDamage)
	emit_signal("action_performed", str(self.name + " attacked " + target.name + "!"))
	emit_signal("turn_finished")

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
		emit_signal("dead")
