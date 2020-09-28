extends Node

export (NodePath) var combatants_node

var queue = [] setget set_queue
var active_combatant = null setget set_active_combatant

func _ready():
	combatants_node = get_node(combatants_node)

func initialize():
	set_queue(combatants_node.get_children())
	play_turn()

func play_turn():
	yield(active_combatant, "turn_finished")
	get_next_in_queue()
	play_turn()

#WARNING: function is currently unused
func remove(combatant):
	var new_queue = []
	for n in queue:
		new_queue.append(n)
	new_queue.remove(new_queue.find(combatant))
	combatant.queue_free() #Deletes node from scene tree
	self.queue = new_queue

func set_queue(node_queue):
	queue.clear()
	for combatant in node_queue:
		queue.append(combatant)
		combatant.active = false
	if not queue.empty():
		self.active_combatant = queue[0]
	else:
		print("Error: Cannot set active combatant; no combatants have been defined in node_queue")

func get_next_in_queue():
	var previous_combatant = queue.pop_front()
	previous_combatant.active = false
	queue.append(previous_combatant)
	self.active_combatant = queue[0]
	return active_combatant #WARNING: this return statement is currently unused

func set_active_combatant(new_combatant):
	active_combatant = new_combatant
	active_combatant.active = true
#	emit_signal("active_combatant_changed", active_combatant)
