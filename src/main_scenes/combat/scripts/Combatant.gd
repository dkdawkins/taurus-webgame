extends Node2D

enum State {ALIVE, DEAD, FLED}

onready var status_icons = get_node("StatusIcons")
onready var sfx = get_node("CombatantSFX")

var damage_popup = preload("res://main_scenes/combat/scenes/DamagePopup.tscn")

var damaged_sound = preload("res://main_scenes/_shared/assets/524046__monirec__generic-impact.wav")
var attacking_sound = preload("res://main_scenes/_shared/assets/524046__monirec__generic-impact.wav")
var dead_sound = preload("res://main_scenes/_shared/assets/524046__monirec__generic-impact.wav")

var hitPoints = 1
var maxHitPoints = 1
var attackPoints = 1
var defensePoints = 1
var evadeChance = 0
var statuses = []
var lastSingleTarget = null

var sprites
var ability_data
var active = false setget set_active
var state = State.ALIVE setget set_state

signal action_performed(actionDialog)
signal stance_changed(action)
signal combatant_selected
signal turn_finished
signal awaiting_target
signal acquired_target
signal hitPoints_changed
signal state_changed

func initialize(combatant_stats, ability_dict):
	sprites = load(combatant_stats["sprites"]).instance()
	sprites.connect("input_event", self, "_on_input_event")
	self.add_child(sprites)
	self.set_name(combatant_stats["name"])
	ability_data = ability_dict
	hitPoints = combatant_stats["hp"]
	maxHitPoints = combatant_stats["hp"]
	attackPoints = combatant_stats["ap"]
	defensePoints = combatant_stats["dp"]
	evadeChance = combatant_stats["ec"]

func set_active(isCombatantActive):
	active = isCombatantActive
	#Update statuses
	if active:
		var turnSkipped = false
		var statusesToRemove = []
		for status in statuses:
			if status["type"] == "Stance":
				continue
			status["length"] -= 1
			if status["length"] <= 0:
				statusesToRemove.append(status)
			else:
				if status["turnSkipped"] == true:
					turnSkipped = true
		for status in statusesToRemove:
			expire_status(status)
		if turnSkipped:
			active = false
			yield(get_tree().create_timer(0.5), "timeout")
			emit_signal("turn_finished")

func set_state(combatantState):
	state = combatantState
	emit_signal("state_changed")

func perform_action(actionName):
	var action = ability_data[actionName]
	var stanceChanged = false
	var endTurn = false
	if action["name"] != "Flee":
		if self.is_in_group("Players"):
			if action["effects"][0]["target"] == "Single Enemy":
				emit_signal("awaiting_target")
				lastSingleTarget = yield(get_parent().get_parent(), "return_selection")
				emit_signal("acquired_target")
			play_sound(attacking_sound)
			play_animation("Acting")
		elif self.is_in_group("Enemies"):
			play_sound(attacking_sound)
			play_animation("Acting", true)
		for effect in action["effects"]:
			if effect["type"] != "Stance":
				endTurn = true
			var targets = get_targets(effect["target"])
			for target in targets:
				for n in range(effect["numHits"]):
					if effect["type"] == "Stance":
						stanceChanged = true
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
							break
					#Add any lingering effects to the target
					if effect["length"] > 0:
						target.add_status(effect.duplicate(true))
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
	emit_signal("action_performed", action, lastSingleTarget)
	if stanceChanged:
		emit_signal("stance_changed", action)
	lastSingleTarget = null
	if endTurn:
		emit_signal("turn_finished")
	elif self.is_in_group("Enemies"):
		self.get_action()

func take_damage(damage):
	var evaded = false
	var actualDamage = 0
	if (randi() % 100) >= evadeChance:
		actualDamage = damage - defensePoints
		if actualDamage > 0:
			var prevHitPoints = hitPoints
			hitPoints -= actualDamage
			emit_signal("hitPoints_changed")
			if (hitPoints <= 0) and (prevHitPoints > 0):
				self.state = State.DEAD
				play_sound(dead_sound)
				play_animation("Death")
			elif (hitPoints > 0):
				play_sound(damaged_sound)
				play_animation("Damaged")
		else:
			actualDamage = 0
	else:
		evaded = true
	var popup = damage_popup.instance()
	popup.type = "Damage"
	if evaded:
		popup.text = "EVADED"
	else:
		popup.text = str(actualDamage)
	add_child(popup)

func heal_damage(heal):
	var actualHeal = heal
	if actualHeal > 0:
		hitPoints += actualHeal
		if hitPoints > maxHitPoints:
			actualHeal -= hitPoints - maxHitPoints
			hitPoints = maxHitPoints
		emit_signal("hitPoints_changed")
		#TODO: Play animations/sounds
	var popup = damage_popup.instance()
	popup.type = "Heal"
	popup.text = str(heal)
	add_child(popup)

func add_status(status):
	var offset = 0
	var statusIcon = TextureRect.new()
	statusIcon.texture = load(status["icon"])
	statusIcon.rect_scale = Vector2(0.5, 0.5)
	statusIcon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for _icon in status_icons.get_children():
		offset += 25
	statusIcon.rect_position.x += offset
	status_icons.add_child(statusIcon)
	self.statuses.append(status)

#Reverses the effects of the given status
func expire_status(status):
	var index = statuses.find(status)
	var iconToRemove = status_icons.get_child(index)
	status_icons.remove_child(iconToRemove)
	for n in range(index, status_icons.get_child_count()):
		status_icons.get_child(n).rect_position.x -= 25
	for n in range(status["numHits"]):
		match status["statAffected"]:
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
	self.statuses.erase(status)

func play_animation(name, reverse=false):
	sprites.get_node("AnimatedSprite").play(name, reverse)
	yield(sprites.get_node("AnimatedSprite"), "animation_finished")
	if state != State.DEAD:
		sprites.get_node("AnimatedSprite").set_animation("Idle")

func play_sound(sound_effect):
	sfx.stream = sound_effect
	sfx.play()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		emit_signal("combatant_selected")

func get_action():
	print("Base get_action function called; this should not happen")
func get_targets(_type):
	print("Base get_target function called; this should not happen")
