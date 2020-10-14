extends Node2D

enum State {ALIVE, DEAD}

#declare default combatant stats here
var hitPoints = 1
var maxHitPoints = 1
var attackPoints = 1
var defensePoints = 1
var evadeChance = 0
var statuses = []	#Stores any statuses currently affecting the combatant
var lastTarget = null	#Stores the last target for actions with multiple effects

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
	evadeChance = combatant_stats["ec"]
	self.set_name(combatant_stats["name"])

func set_active(isCombatantActive):
	active = isCombatantActive

func set_state(combatantState):
	state = combatantState
	emit_signal("state_changed")

func perform_action(actionName):
	var action = ability_data[actionName]
	#TODO: display action 
	for effect in action["effects"]:
		var targets = get_targets(effect["target"])
		for target in targets:
			match effect["type"]:
				#TODO: add a separate function for damage, heal, and stat calculations
				"Damage":
					for n in range(effect["numHits"]):
						#TODO: check evasion and update statuses
						target.take_damage((attackPoints*(effect["modifier"]/50)))
				"Heal":
					#TODO: update statuses
					target.heal_damage((attackPoints*(effect["modifier"]/50)))
				"Debuff":
					continue
				"Buff":
					match effect["statAffected"]:
						"hitPoints":
							target.hitPoints = hitPoints*(effect["modifier"]/50)
							emit_signal("hitPoints_changed")
						"maxHitPoints": 
							target.maxHitPoints = maxHitPoints*(effect["modifier"]/50)
							emit_signal("hitPoints_changed")
						"attackPoints": 
							target.attackPoints = attackPoints*(effect["modifier"]/50)
						"defensePoints": 
							target.defensePoints = defensePoints*(effect["modifier"]/50)
						"evadeChance": 
							target.evadeChance += effect["modifier"]
					target.statuses.append(effect.duplicate(true))
				"Stance":
					pass
				"Status":
					target.statuses.append(effect.duplicate(true))
		
	lastTarget = null
	print(str(self.name + " used " + actionName))	#FOR TESTING ONLY
	emit_signal("turn_finished")

#func apply_damage_effect(effect):
#	var actionDamage = attackPoints * (effect["modifier"] / 50) #TODO: improve damage calculation
#	var targets = get_targets(effect["target"])
#	for n in range(effect["numHits"]):
#		for target in targets:
#			target.take_damage(actionDamage)
#
#func apply_heal_effect(effect):
#	var actionHeal = attackPoints * (effect["modifier"] / 50) #TODO: improve heal calculation
#	var targets = get_targets(effect["target"])
#	for target in targets:
#		target.heal_damage(actionHeal)
#
#func apply_status_effect(effect):
#	pass
#
#func apply_buff_effect(effect):
#	pass

func take_damage(damage):
	var actualDamage = damage - defensePoints
	if actualDamage > 0:
		hitPoints -= actualDamage
		
		#TODO: Play animations/sounds
		
		emit_signal("hitPoints_changed")
		if hitPoints <= 0:
			self.state = State.DEAD

func heal_damage(heal):
	if heal > 0:
		hitPoints += heal
		if hitPoints > maxHitPoints:
			hitPoints = maxHitPoints
		emit_signal("hitPoints_changed")
		
		#TODO: Play animations/sounds

func expire_status(status):
	pass
	
func get_targets(_type):
	print("Base get_target function called; this should not happen")
