extends Control

export (NodePath) var combatants_node
export (PackedScene) var character_info_scene

var abilities

func _ready():
	combatants_node = get_node(combatants_node)

func initialize(ability_library):
	abilities = ability_library
	var character_info
	for combatant in combatants_node.get_children():
		connect_combatant_signals(combatant)
		if combatant.is_in_group("Players"):
			character_info = character_info_scene.instance()
			character_info.name = combatant.name
			character_info.get_node("Status").text = "No Stance"
			character_info.get_node("Health").text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
			character_info.get_node("Name").text = combatant.name
			$PlayerPanel/PlayerInfo.add_child(character_info)

func clear_data():
	for button in $PlayerPanel/SecondaryButtons/VBoxContainer.get_children():
		if button.name != "Back":
			button.queue_free()
	for info in $PlayerPanel/PlayerInfo.get_children():
		info.queue_free()

func connect_combatant_signals(combatant):
		combatant.connect("hitPoints_changed", self, "_on_hitPoints_changed", [combatant])
		combatant.connect("state_changed", self, "_on_state_changed", [combatant])
		combatant.connect("stance_changed", self, "_on_stance_changed", [combatant])
		combatant.connect("action_performed", self, "_on_action_performed", [combatant])
		combatant.connect("awaiting_target", self, "_on_awaiting_target")
		combatant.connect("acquired_target", self, "_on_acquired_target")

func _on_Attack_pressed():
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.attack()
			return

func _on_Secondary_pressed(name):
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.secondary(name)
			return

func _on_Special_pressed():
	#Add Secondary buttons for each special in combatant.specials
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			$PlayerPanel/PrimaryButtons.hide()
			for special in combatant.specialAbilities:
				var button = ToolButton.new()
				button.name = special	#WARNING: this value is used by other functions
				button.text = abilities[special]["name"]
				button.align = HALIGN_LEFT
				button.connect("button_down", self, "_on_Secondary_pressed", [button.name])
				$PlayerPanel/SecondaryButtons/VBoxContainer.add_child(button)
				button.show()
			$PlayerPanel/SecondaryButtons.show()
			return

func _on_Stance_pressed():
	#Add Secondary buttons for each stance in combatant.stances
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			$PlayerPanel/PrimaryButtons.hide()
			for stance in combatant.stances:
				var button = ToolButton.new()
				button.name = stance
				button.text = abilities[stance]["name"]
				button.align = HALIGN_LEFT
				button.connect("button_down", self, "_on_Secondary_pressed", [button.name])
				$PlayerPanel/SecondaryButtons/VBoxContainer.add_child(button)
				button.show()
			$PlayerPanel/SecondaryButtons.show()
			return

func _on_Item_pressed():
	#TODO: implement me
	pass

func _on_Flee_pressed():
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.flee()
			return

func _on_Back_pressed():
	for button in $PlayerPanel/SecondaryButtons/VBoxContainer.get_children():
		if button.name != "Back":
			button.queue_free()
	$PlayerPanel/SecondaryButtons.hide()
	$PlayerPanel/PrimaryButtons.show()

func _on_awaiting_target():
	#Hide menu buttons while the player selects a target
	$PlayerPanel/PrimaryButtons.hide()
	for button in $PlayerPanel/SecondaryButtons/VBoxContainer.get_children():
		if button.name != "Back":
			button.queue_free()
	$PlayerPanel/SecondaryButtons.hide()
	$DialogPopup/DialogText.text = "Please select a target"
	$DialogPopup.show()

func _on_acquired_target():
	$PlayerPanel/PrimaryButtons.show()

func _on_hitPoints_changed(combatant):
	if combatant.is_in_group("Players"):
		var character_info = $PlayerPanel/PlayerInfo.get_node(combatant.name)
		character_info.get_node("Health").text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)

func _on_stance_changed(action, combatant):
	if combatant.is_in_group("Players"):
		var character_info = $PlayerPanel/PlayerInfo.get_node(combatant.name)
		character_info.get_node("Status").text = str(action["name"])

func _on_state_changed(combatant):
	yield(get_tree().create_timer(0.75), "timeout")
	match combatant.state:
		combatant.State.FLED:
			$DialogPopup/DialogText.text = str(combatant.name + " has fled from the battle!")
			$DialogPopup.show()
		combatant.State.DEAD:
			$DialogPopup/DialogText.text = str(combatant.name + " has died!")
			$DialogPopup.show()

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
