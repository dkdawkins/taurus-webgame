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
	remove_child(combat_scene)
	
	#FOR TESTING ONLY
	var combatants = ["Enemy", "Player"]
	start_combat(combatants)


func start_combat(combatants):
	#TODO: play any animations
	#remove_child(exploration_scene)
	add_child(combat_scene)
	combat_scene.show()
	combat_scene.initialize(combatants)


func _on_combat_finished(winners, losers):
	remove_child(combat_scene)
	#add_child(exploration_scene)
	#TODO: return any needed data to exploration scene
	#TODO: replace print statements with dialogs
	print(str("Winners: " + winners[0].name))
	print(str("Losers: " + losers[0].name))
	combat_scene.clear_combat()
