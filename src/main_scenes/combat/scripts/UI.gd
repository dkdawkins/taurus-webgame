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


func set_single_target(type):
	#TODO: replace below code with proper UI targeting system
	match type:
		"Single Enemy":
			for combatant in combatants_node.get_children():
				if combatant.is_in_group("Enemies") and combatant.state == combatant.State.ALIVE:
					return combatant
		"Single Ally":
			for combatant in combatants_node.get_children():
				if combatant.is_in_group("Players") and combatant.state == combatant.State.ALIVE:
					return combatant


func _on_Attack_pressed():
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.attack()
			return


func _on_Special_pressed():
	#Perform Special (variation based on stance)
	pass # Replace with function body.


func _on_Stance_pressed():
	#Open Stance menu
	pass # Replace with function body.


func _on_Item_pressed():
	#Open Item menu (or use potion if this version only has potion items)
	pass # Replace with function body.


func _on_Flee_pressed():
	#Escape from battle
	pass # Replace with function body.

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
