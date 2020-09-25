extends Control

export (NodePath) var combatants_node
const PC = preload("res://main_scenes/combat/scripts/PlayerCombatant.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	combatants_node = get_node(combatants_node)

func initialize():
	#initialize UI data
	for combatant in combatants_node.get_children():
		if combatant is PC:
			#In the future, Characters should be added dynamically, rather than formatting a preset
			$PlayerPanel/PlayerInfo/Character/Health.text = str(combatant.hitPoints) + "/" + str(combatant.maxHitPoints)
			$PlayerPanel/PlayerInfo/Character/Name.text = "InitializedPlayer"
			$PlayerPanel/PlayerInfo/Character/Status.text = "InitializedStance"


func _on_Attack_pressed():
	#Perform Attack (variation based on stance)
	pass # Replace with function body.


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
