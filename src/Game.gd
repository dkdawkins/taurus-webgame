extends Node

export(NodePath) var main_menu
export(NodePath) var exploration_scene
export(NodePath) var combat_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu = get_node(main_menu)
	exploration_scene = get_node(exploration_scene)
	combat_scene = get_node(combat_scene)
	
	remove_child(main_menu)
	remove_child(exploration_scene)
	
	#FOR TESTING ONLY
	var combatants = ["Player", "Enemy"]
	combat_scene.initialize(combatants)
