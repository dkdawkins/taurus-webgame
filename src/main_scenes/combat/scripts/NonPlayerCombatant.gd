extends "res://main_scenes/combat/scripts/Combatant.gd"

const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")

func set_active(isCombatantActive):
	active = isCombatantActive
	if not active:
		return
	$ActionDelay.start()
	yield($ActionDelay, "timeout")
	#Target and attack the first PC found
	var target
	for combatant in get_parent().get_children():
		if combatant is PC:
			target = combatant
			break
	perform_action("attack", target)

##	FOR TESTING ONLY
#	perform_action("attack", get_parent().get_node("PlayerCombatant"))
