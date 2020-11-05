extends Node

export (NodePath) var combatants_node

var queue = [] setget set_queue
var active_combatant = null setget set_active_combatant

signal queue_finished(pc_state, npc_state)

func _ready():
	combatants_node = get_node(combatants_node)

func initialize():
	set_queue(combatants_node.get_children())
	play_turn()

func play_turn():
	yield(active_combatant, "turn_finished")
	if check_queue_state(): #Do not continue unless combat is still in progress
		get_next_in_queue()
		play_turn()

func remove(combatant):
	if not queue.has(combatant):
		print("Error: combatant does not exist in queue")
		return
	var new_queue = []
	for n in queue:
		new_queue.append(n)
	new_queue.remove(new_queue.find(combatant))
	self.queue = new_queue

func set_queue(node_queue):
	queue.clear()
	for combatant in node_queue:
		if not combatant.is_connected("state_changed", self, "_on_state_changed"):
			combatant.connect("state_changed", self, "_on_state_changed", [combatant])
		queue.append(combatant)
		combatant.active = false
	if (not queue.empty()) and (active_combatant == null):
		self.active_combatant = queue[0]

func clear_queue():
	queue.clear()

func get_next_in_queue():
	var previous_combatant = active_combatant
	if previous_combatant == queue[0]:
		queue.pop_front()
		queue.append(previous_combatant)
	previous_combatant.active = false
	self.active_combatant = queue[0]

func check_queue_state():
	var hasPCs = false
	var hasNPCs = false
	for combatant in queue:
		if combatant.is_in_group("Players"):
			hasPCs = true
		elif combatant.is_in_group("Enemies"):
			hasNPCs = true
	if (not hasPCs) or (not hasNPCs):
		emit_signal("queue_finished", hasPCs, hasNPCs)
		return false
	return true

func set_active_combatant(new_combatant):
	active_combatant = new_combatant
	active_combatant.active = true

func _on_state_changed(combatant):
	if (combatant.state == combatant.State.DEAD) or (combatant.state == combatant.State.FLED):
		remove(combatant)
