extends Node2D

export (PackedScene) var player_combatant_scene
export (PackedScene) var non_player_combatant_scene

const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")
const NPC = preload("res://main_scenes/combat/scripts/NonPlayerCombatant.gd")

signal combat_finished(winners, losers)

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
		n.queue_free()
	#TODO: clear combatant information from UI (after dynamic character display is implemented)
