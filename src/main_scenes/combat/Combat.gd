extends Node2D

export (PackedScene) var player_combatant_scene
export (PackedScene) var non_player_combatant_scene

#const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")
#const NPC = preload("res://main_scenes/combat/scripts/NonPlayerCombatant.gd")

signal combat_finished(winners, losers)

var npc_data
var pc_data
var ability_data

func initialize(npc_dict, pc_dict, ability_dict, combatant_keys):
	npc_data = npc_dict
	pc_data = pc_dict
	ability_data = ability_dict
	
	var combatant
	var combatant_data
	for combatant_key in combatant_keys:
		#WARNING: Keys must be unique for every enemy/player; otherwise, incorrect data may be loaded
		if npc_data.has(combatant_key):
			combatant = non_player_combatant_scene.instance()
			combatant.add_to_group("Enemies")
			combatant_data = npc_data[combatant_key]
		elif pc_data.has(combatant_key):
			combatant = player_combatant_scene.instance()
			combatant.add_to_group("Players")
			combatant_data = pc_data[combatant_key]
		$Combatants.add_child(combatant)
		set_combatant_position(combatant, combatant_data)
		combatant.initialize(combatant_data, ability_data)
	$UI.initialize()
	$TurnQueue.initialize()


func set_combatant_position(combatant, combatant_data):
	var position = int(combatant_data["position"])
	match position:
		1:
			combatant.transform = $Positions/Players/Player1.transform
		2:
			combatant.transform = $Positions/Players/Player2.transform
		3:
			combatant.transform = $Positions/Players/Player3.transform
		4:
			combatant.transform = $Positions/Players/Player4.transform
		5:
			combatant.transform = $Positions/Enemies/Enemy1.transform
		6:
			combatant.transform = $Positions/Enemies/Enemy2.transform
		7:
			combatant.transform = $Positions/Enemies/Enemy3.transform
		8:
			combatant.transform = $Positions/Enemies/Enemy4.transform
		9:
			combatant.transform = $Positions/Enemies/Enemy5.transform
		_:
			pass
			#TODO: implement semi-random positioning
#			if combatant.is_in_group("Players"):
#				#Iterate through children of Positions/Players
#				for position in $Positions/Players.get_children():
#
#				#If position is occupied by a collision box, continue iterating
#				#If not, place combatant at this position and exit loop
#			elif combatant.is_in_group("Enemies"):
#				#See above
#				pass

func _on_queue_finished(pc_won, npc_won):
	#Determine winners and losers
	var winners = []
	var losers = []
	if pc_won:
		for combatant in $Combatants.get_children():
			if combatant.is_in_group("Players"):
				winners.append(combatant)
			elif combatant.is_in_group("Enemies"):
				losers.append(combatant)
	elif npc_won:
		for combatant in $Combatants.get_children():
			if combatant.is_in_group("Players"):
				losers.append(combatant)
			elif combatant.is_in_group("Enemies"):
				winners.append(combatant)
	finish_combat(winners, losers)


func finish_combat(winners, losers):
	emit_signal("combat_finished", winners, losers)


func clear_combat():
	for n in $Combatants.get_children():
		n.active = false
		n.queue_free()
	#TODO: clear combatant information from UI (after dynamic character display is implemented)
