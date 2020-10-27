extends Node2D

enum State {ALIVE, DEAD, FLED}

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
	#Update status durations and expire statuses that reach zero
	if active:
		var statusesToRemove = []
		for status in statuses:
			if status["type"] == "Stance":	#Do not automatically remove stances
				continue
			status["length"] -= 1
			if status["length"] <= 0:
				expire_status(status)
				statusesToRemove.append(status)
		for status in statusesToRemove:
			statuses.erase(status)

func set_state(combatantState):
	state = combatantState
	emit_signal("state_changed")

func perform_action(actionName):
	var action = ability_data[actionName]
	var endTurn = false
	#TODO: display action
	if action["name"] != "Flee":
		for effect in action["effects"]:
			if effect["type"] != "Stance":
				endTurn = true
			var targets = get_targets(effect["target"])
			for target in targets:
				for n in range(effect["numHits"]):
					match effect["statAffected"]:
						"hitPoints":
							if effect["type"] == "Damage":
								target.take_damage(attackPoints*(effect["modifier"]/50))
							elif effect["type"] == "Heal":
								target.heal_damage(attackPoints*(effect["modifier"]/50))
						"maxHitPoints":
							target.maxHitPoints = maxHitPoints*(effect["modifier"]/50)
							if target.maxHitPoints < target.hitPoints:
								target.hitPoints = target.maxHitPoints
							emit_signal("hitPoints_changed")
						"attackPoints": 
							target.attackPoints = attackPoints*(effect["modifier"]/50)
						"defensePoints": 
							target.defensePoints = defensePoints*(effect["modifier"]/50)
						"evadeChance": 
							target.evadeChance += effect["modifier"]
					#Check target for statuses that this effect removes
					for status in target.statuses:
						if status["cancelEffect"] == effect["type"]:
							target.expire_status(status)
							print(str(status["type"] + " stripped from target!"))	#FOR TESTING
							target.statuses.erase(status)
							break
					#Add any lingering effects to the target
					if effect["length"] > 0:
						target.statuses.append(effect.duplicate(true))
						#TODO: display status effects
				#Add any abilities unlocked by effects to the player's special menu
				for ability in effect["unlockedAbilities"]:
					if target.is_in_group("Players"):
						target.specialAbilities.append(ability)
	else:
		endTurn = true
		if self.is_in_group("Players"):
			#Remove all player characters from combat (effectively ending combat)
			for combatant in get_parent().get_children():
				if combatant.is_in_group("Players") and state != State.DEAD:
					combatant.state = State.FLED
		elif self.is_in_group("Enemies"):
			#Remove this enemy from combat
			self.state = State.FLED
	lastTarget = null
	print(str(self.name + " used " + actionName))	#FOR TESTING ONLY
	if endTurn:
		emit_signal("turn_finished")
	elif self.is_in_group("Enemies"):
		self.get_action()

func take_damage(damage):
	if (randi() % 100) >= evadeChance:
		var actualDamage = damage - defensePoints
		if actualDamage > 0:
			hitPoints -= actualDamage
			
			#TODO: Play animations/sounds
			
			emit_signal("hitPoints_changed")
			if hitPoints <= 0:
				self.state = State.DEAD
	else:
		print(str(self.name + " evaded the attack!"))	#FOR TESTING

func heal_damage(heal):
	if heal > 0:
		hitPoints += heal
		if hitPoints > maxHitPoints:
			hitPoints = maxHitPoints
		emit_signal("hitPoints_changed")
		
		#TODO: Play animations/sounds

#Reverses the effects of the given status
func expire_status(status):
	for n in range(status["numHits"]):
		match status["statAffected"]:
#			"hitPoints":
#				if status["type"] == "Damage":
#					heal_damage(attackPoints*(status["modifier"]/50))
#				elif status["type"] == "Heal":
#					take_damage(attackPoints*(status["modifier"]/50))
			"maxHitPoints":
				maxHitPoints = maxHitPoints/(status["modifier"]/50)
				if maxHitPoints < hitPoints:
					hitPoints = maxHitPoints
				emit_signal("hitPoints_changed")
			"attackPoints": 
				attackPoints = attackPoints/(status["modifier"]/50)
			"defensePoints": 
				defensePoints = defensePoints/(status["modifier"]/50)
			"evadeChance": 
				evadeChance -= status["modifier"]
	for ability in status["unlockedAbilities"]:
		if self.is_in_group("Players"):
			self.specialAbilities.remove(ability)

func get_action():
	print("Base get_action function called; this should not happen")
func get_targets(_type):
	print("Base get_target function called; this should not happen")
