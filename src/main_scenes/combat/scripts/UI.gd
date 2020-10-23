extends Control

export (NodePath) var combatants_node
export (PackedScene) var character_info_scene

func _ready():
	combatants_node = get_node(combatants_node)

func initialize():
	var character_info
	for combatant in combatants_node.get_children():
		combatant.connect("hitPoints_changed", self, "_on_hitPoints_changed", [combatant])
		combatant.connect("state_changed", self, "_on_state_changed", [combatant])
		combatant.connect("action_performed", self, "_on_action_performed")
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
	#Escape from battle
	pass # Replace with function body.


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


func _on_hitPoints_changed(combatant):
	if combatant.is_in_group("Players"):
		var character_info = $PlayerPanel/PlayerInfo.get_node(combatant.name)
		character_info.get_node("Health").text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
		#$PlayerPanel/PlayerInfo/Character/Health.text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)

func _on_state_changed(combatant):
	#TODO: print state change to a popup
	print(combatant.state)

func _on_action_performed(actionDialog):
	#TODO: print action dialog to a popup
	print(actionDialog)
