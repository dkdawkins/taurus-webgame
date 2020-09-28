extends Node2D

#declare combatant stats here
var active = false setget set_active
var hitPoints = 1
var maxHitPoints = 1

signal turn_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(hp):
	#initialize stats
	hitPoints = hp
	maxHitPoints = hp

func set_active(isCombatantActive):
	active = isCombatantActive

func take_damage(damage):
	hitPoints -= damage
