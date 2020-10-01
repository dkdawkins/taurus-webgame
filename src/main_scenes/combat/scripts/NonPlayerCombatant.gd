extends "res://main_scenes/combat/scripts/Combatant.gd"

const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")

func initialize(hp):
	.initialize(hp)

func set_active(isCombatantActive):
	active = isCombatantActive
	if not active:
		return

	#Wait for TurnQueue to reach yield statement before performing action
	$ActionDelay.start()
	yield($ActionDelay, "timeout")
	
	#Target and attack the first PC found
	var target
	for combatant in get_parent().get_children():
		if combatant is PC:
			target = combatant
			break
	perform_action("attack", target)
