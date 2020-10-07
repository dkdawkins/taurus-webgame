extends Node2D

export (PackedScene) var player_combatant_scene
export (PackedScene) var non_player_combatant_scene

const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")
const NPC = preload("res://main_scenes/combat/scripts/NonPlayerCombatant.gd")

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
			combatant_data = npc_data[combatant_key]
		elif pc_data.has(combatant_key):
			combatant = player_combatant_scene.instance()
			combatant_data = pc_data[combatant_key]
		$Combatants.add_child(combatant)
		combatant.initialize(combatant_data)
	$UI.initialize()
	$TurnQueue.initialize()


func _on_queue_finished(pc_won, npc_won):
	#Determine winners and losers
	var winners = []
	var losers = []
	if pc_won:
		for combatant in $Combatants.get_children():
			if combatant is PC:
				winners.append(combatant)
			elif combatant is NPC:
				losers.append(combatant)
	elif npc_won:
		for combatant in $Combatants.get_children():
			if combatant is PC:
				losers.append(combatant)
			elif combatant is NPC:
				winners.append(combatant)
	finish_combat(winners, losers)


func finish_combat(winners, losers):
	emit_signal("combat_finished", winners, losers)


func clear_combat():
	for n in $Combatants.get_children():
		n.active = false
		n.queue_free()
	#TODO: clear combatant information from UI (after dynamic character display is implemented)
