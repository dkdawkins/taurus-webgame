extends Node

export(NodePath) var main_menu
export(NodePath) var exploration_scene
export(NodePath) var combat_scene

var npc_data
var pc_data
var ability_data

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()
	randomize() #Set seed for any random number calls
	
	main_menu = get_node(main_menu)
	exploration_scene = get_node(exploration_scene)
	combat_scene = get_node(combat_scene)
	
	remove_child(main_menu)
	remove_child(exploration_scene)
	remove_child(combat_scene)
	
	#FOR TESTING ONLY
	##################
	
#	print(str(npc_data["wolf"]["name"], " used ", ability_data["bite"]["name"], "!"))
	var combatants = ["knight", "david", "ken"] #Keys corresponding to dict objects in npc_data or pc_data
	start_combat(combatants)
	
	##################


func start_combat(combatants):
	#TODO: play any animations
	#remove_child(exploration_scene)
	add_child(combat_scene)
	combat_scene.show()
	combat_scene.initialize(npc_data, pc_data, ability_data, combatants)


#TODO: find a more efficient way to load multiple files
func load_data():
	var text
	var data
	var file = File.new()
	if file.open("res://main_scenes/_shared/data/npc_data.json", File.READ) == OK:
		text = file.get_as_text()
		file.close()
		data = JSON.parse(text)
		if data.error == OK:
			npc_data = data.result
		else:
			print("Failed to parse JSON in npc_data")
	else:
		print("Failed to load npc_data")
		
	if file.open("res://main_scenes/_shared/data/pc_data.json", File.READ) == OK:
		text = file.get_as_text()
		file.close()
		data = JSON.parse(text)
		if data.error == OK:
			pc_data = data.result
		else:
			print("Failed to parse JSON in pc_data")
	else:
		print("Failed to load pc_data")
		
	if file.open("res://main_scenes/_shared/data/ability_data.json", File.READ) == OK:
		text = file.get_as_text()
		file.close()
		data = JSON.parse(text)
		if data.error == OK:
			ability_data = data.result
		else:
			print("Failed to parse JSON in ability_data")
	else:
		print("Failed to load ability_data")


func _on_combat_finished(winners, losers):
	remove_child(combat_scene)
	#add_child(exploration_scene)
	#TODO: return any needed data to exploration scene
	#TODO: replace print statements with dialogs
	print(str("Winners: " + winners[0].name))
	print(str("Losers: " + losers[0].name))
	combat_scene.clear_combat()
