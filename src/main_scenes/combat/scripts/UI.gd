extends Control

export (NodePath) var combatants_node
#export (NodePath) var turn_queue_node
#const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")
#const NPC = preload("res://main_scenes/combat/scripts/NonPlayerCombatant.gd")

func _ready():
	combatants_node = get_node(combatants_node)

func initialize():
	#initialize UI data
	for combatant in combatants_node.get_children():
		combatant.connect("hitPoints_changed", self, "_on_hitPoints_changed", [combatant])
		combatant.connect("state_changed", self, "_on_state_changed", [combatant])
		combatant.connect("action_performed", self, "_on_action_performed")
		if combatant.is_in_group("Players"):
			#TODO: add characters dynamically and reference by name
			$PlayerPanel/PlayerInfo/Character/Health.text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
			$PlayerPanel/PlayerInfo/Character/Name.text = "InitializedPlayer"
			$PlayerPanel/PlayerInfo/Character/Status.text = "InitializedStance"


func set_single_target(type):
	#TODO: implement targeting system
	match type:
		"Single Enemy":
			for combatant in combatants_node.get_children():
				if combatant.is_in_group("Enemies"):
					return combatant
		"Single Ally":
			for combatant in combatants_node.get_children():
				if combatant.is_in_group("Players"):
					return combatant


func _on_Attack_pressed():
	for combatant in combatants_node.get_children():
		if (combatant.active) and (combatant.is_in_group("Players")):
			combatant.perform_action("attack") 


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
		#TODO: reference character by name (see TODO in initialize)
		$PlayerPanel/PlayerInfo/Character/Health.text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
		
func _on_state_changed(combatant):
	#TODO: print state change to a popup
	print(combatant.state)

func _on_action_performed(actionDialog):
	#TODO: print action dialog to a popup
	print(actionDialog)
