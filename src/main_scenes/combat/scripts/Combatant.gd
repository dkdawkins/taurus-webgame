extends Node2D

#declare combatant stats here
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

func take_damage(damage):
	hitPoints -= damage
