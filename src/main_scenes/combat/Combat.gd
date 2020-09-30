extends Node2D

export (PackedScene) var player_combatant_scene
export (PackedScene) var non_player_combatant_scene

func initialize(combatants_data):
	#initialize scene nodes/objects
	var combatant
	for combatant_data in combatants_data:
		if combatant_data == "Player":
			combatant = player_combatant_scene.instance()
		elif combatant_data == "Enemy":
			combatant = non_player_combatant_scene.instance()
		$Combatants.add_child(combatant)
		combatant.initialize(10)	#TODO: replace this with combatant_data; unique identifiers should also be defined
	$UI.initialize()
	$TurnQueue.initialize()

func _on_queue_finished(pc_state, npc_state):
	#TODO: finish combat
	if npc_state == false:
		print("Player won!")
	else:
		print("Enemy won!")
