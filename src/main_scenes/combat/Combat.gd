extends Node2D

export (PackedScene) var player_combatant_scene
export (PackedScene) var non_player_combatant_scene

signal combat_finished(winners, losers)
signal return_selection(combatant)

var npc_library
var pc_library
var ability_library

func initialize(npc_dict, pc_dict, ability_dict, combatant_keys):
	npc_library = npc_dict
	pc_library = pc_dict
	ability_library = ability_dict
	
	var combatant_scene
	var combatant_stats
	var positions_reserved = []
	
	for position in $Positions/Players.get_children():
		positions_reserved.append(false)
	for position in $Positions/Enemies.get_children():
		positions_reserved.append(false)
		
	for combatant_key in combatant_keys:
		if npc_library.has(combatant_key):
			combatant_scene = non_player_combatant_scene.instance()
			combatant_scene.add_to_group("Enemies")
			combatant_stats = npc_library[combatant_key]
		elif pc_library.has(combatant_key):
			combatant_scene = player_combatant_scene.instance()
			combatant_scene.add_to_group("Players")
			combatant_stats = pc_library[combatant_key]
		$Combatants.add_child(combatant_scene)
		combatant_scene.initialize(combatant_stats, ability_library)
		combatant_scene.connect("combatant_selected", self, "_on_combatant_selected", [combatant_scene])
		set_combatant_position(combatant_scene, combatant_stats, positions_reserved)
	$UI.initialize(ability_library)
	$TurnQueue.initialize()


func set_combatant_position(combatant_scene, combatant_stats, positions_reserved):
	var combatant_position = null
	if combatant_stats["position"] != null:
		combatant_position = int(combatant_stats["position"])
	match combatant_position:
		1:
			combatant_scene.transform = $Positions/Players/Player1.transform
			positions_reserved[0] = true
		2:
			combatant_scene.transform = $Positions/Players/Player2.transform
			positions_reserved[1] = true
		3:
			combatant_scene.transform = $Positions/Players/Player3.transform
			positions_reserved[2] = true
		4:
			combatant_scene.transform = $Positions/Players/Player4.transform
			positions_reserved[3] = true
		5:
			combatant_scene.transform = $Positions/Enemies/Enemy1.transform
			positions_reserved[4] = true
		6:
			combatant_scene.transform = $Positions/Enemies/Enemy2.transform
			positions_reserved[5] = true
		7:
			combatant_scene.transform = $Positions/Enemies/Enemy3.transform
			positions_reserved[6] = true
		8:
			combatant_scene.transform = $Positions/Enemies/Enemy4.transform
			positions_reserved[7] = true
		9:
			combatant_scene.transform = $Positions/Enemies/Enemy5.transform
			positions_reserved[8] = true
		_:
			var n
			if combatant_scene.is_in_group("Players"):
				n = 0
				for position in $Positions/Players.get_children():
					if not positions_reserved[n]:
						positions_reserved[n] = true
						combatant_scene.transform = position.transform
						return
					n += 1
			elif combatant_scene.is_in_group("Enemies"):
				n = $Positions/Players.get_child_count()
				for position in $Positions/Enemies.get_children():
					if not positions_reserved[n]:
						positions_reserved[n] = true
						combatant_scene.transform = position.transform
						return
					n += 1

func _on_queue_finished(pc_won, npc_won):
	var winners = []
	var losers = []
	if pc_won:
		for combatant_scene in $Combatants.get_children():
			if combatant_scene.is_in_group("Players"):
				winners.append(combatant_scene)
			elif combatant_scene.is_in_group("Enemies"):
				losers.append(combatant_scene)
	elif npc_won:
		for combatant_scene in $Combatants.get_children():
			if combatant_scene.is_in_group("Players"):
				losers.append(combatant_scene)
			elif combatant_scene.is_in_group("Enemies"):
				winners.append(combatant_scene)
	finish_combat(winners, losers)


func _on_combatant_selected(combatant):
	emit_signal("return_selection", combatant)


func finish_combat(winners, losers):
	emit_signal("combat_finished", winners, losers)


func clear_combat():
	for combatants in $Combatants.get_children():
		combatants.active = false
		combatants.queue_free()
	$UI.clear_data()
	$TurnQueue.clear_queue()
