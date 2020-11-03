extends Control

export (NodePath) var combatants_node
export (PackedScene) var character_info_scene
#export (PackedScene) var damage_popup_scene

var damage_popup = preload("res://main_scenes/combat/scenes/DamagePopup.tscn")

func _ready():
	combatants_node = get_node(combatants_node)

func initialize():
	var character_info
	for combatant in combatants_node.get_children():
		combatant.connect("hitPoints_changed", self, "_on_hitPoints_changed", [combatant])
		combatant.connect("combatant_attacked", self, "_on_combatant_attacked", [combatant])
		combatant.connect("combatant_healed", self, "_on_combatant_healed", [combatant])
		combatant.connect("state_changed", self, "_on_state_changed", [combatant])
		combatant.connect("action_performed", self, "_on_action_performed", [combatant])
		combatant.connect("status_added", self, "_on_status_added", [combatant])
		combatant.connect("status_removed", self, "_on_status_removed", [combatant])
		if combatant.is_in_group("Players"):
			character_info = character_info_scene.instance()
			character_info.name = combatant.name
			character_info.get_node("Status").text = "InitializedStatus"
			character_info.get_node("Health").text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
			character_info.get_node("Name").text = combatant.name
			$PlayerPanel/PlayerInfo.add_child(character_info)


func set_single_enemy_target():
	#TODO: replace below code with proper UI targeting system
	for combatant in combatants_node.get_children():
		if combatant.is_in_group("Enemies") and combatant.state == combatant.State.ALIVE:
			return combatant

func set_single_ally_target():
	#TODO: replace below code with proper UI targeting system
	for combatant in combatants_node.get_children():
		if combatant.is_in_group("Players") and combatant.state == combatant.State.ALIVE:
			return combatant

func _on_Attack_pressed():
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.attack()
			return


func _on_Special_pressed():
	#Add Secondary buttons for each special in combatant.specials
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			$PlayerPanel/PrimaryButtons.hide()
			for special in combatant.specialAbilities:
				var button = ToolButton.new()
				button.name = special
				button.text = special	#TODO: pull name from ability dict
				button.align = HALIGN_LEFT
				button.connect("button_down", self, "_on_Secondary_pressed", [button.name])
				$PlayerPanel/SecondaryButtons/VBoxContainer.add_child(button)
				button.show()
			$PlayerPanel/SecondaryButtons.show()
			return


func _on_Stance_pressed():
	#Add Secondary buttons for each special in combatant.stances
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			$PlayerPanel/PrimaryButtons.hide()
			for stance in combatant.stances:
				var button = ToolButton.new()
				button.name = stance
				button.text = stance	#TODO: pull name from ability dict
				button.align = HALIGN_LEFT
				button.connect("button_down", self, "_on_Secondary_pressed", [button.name])
				$PlayerPanel/SecondaryButtons/VBoxContainer.add_child(button)
				button.show()
			$PlayerPanel/SecondaryButtons.show()
			return


func _on_Item_pressed():
	#Show Item menu (or use potion if this version only has potion items)
	pass # Replace with function body.


func _on_Flee_pressed():
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.flee()
			return


func _on_Back_pressed():
	#WARNING: assumes a player character is active, since the secondary menu was accessed
	for button in $PlayerPanel/SecondaryButtons/VBoxContainer.get_children():
		if button.name != "Back":
			button.queue_free()
	$PlayerPanel/SecondaryButtons.hide()
	$PlayerPanel/PrimaryButtons.show()

func _on_Secondary_pressed(name):
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.secondary(name)
			return

func _on_combatant_attacked(damage, evaded, combatant):
	var popup = damage_popup.instance()
	popup.type = "Damage"
	popup.position.x = combatant.position.x
	popup.position.y = combatant.position.y
	if evaded:
		popup.text = "EVADED"
	else:
		popup.text = str(damage)
	add_child(popup)

func _on_combatant_healed(heal, combatant):
	var popup = Label.new()
	popup.rect_position.x = combatant.position.x - 40
	popup.rect_position.y = combatant.position.y - 50
	popup.text = str(heal)
	add_child(popup)
	yield(get_tree().create_timer(1), "timeout")
	popup.queue_free()

func _on_hitPoints_changed(combatant):
	if combatant.is_in_group("Players"):
		var character_info = $PlayerPanel/PlayerInfo.get_node(combatant.name)
		character_info.get_node("Health").text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
		#$PlayerPanel/PlayerInfo/Character/Health.text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)

func _on_state_changed(combatant):
	#Display any state indicators (animations, etc.)
	#Remove combatant from display if their status is DEAD or FLED
	print(combatant.state)

func _on_action_performed(action, target, combatant):
	var actionDialog = action["dialog"]
	if "()" in actionDialog:
		if target != null:
			actionDialog = actionDialog.replace("()", target.get_name())
		else:
			actionDialog = actionDialog.replace("()", combatant.get_name())
	actionDialog = actionDialog.insert(0, combatant.get_name())
	$DialogPopup/DialogText.text = actionDialog
	$DialogPopup.show()

func _on_status_added(status, combatant):
	#TODO: show status icon
	print(str(status["type"] + " added to " + combatant.get_name()))

func _on_status_removed(status, combatant):
	#TODO: remove status icon
	print(str(status["type"] + " removed from " + combatant.get_name()))
