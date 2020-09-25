extends "res://main_scenes/combat/scripts/Combatant.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attack(target):
	#Attack target
	#End turn
	pass
	
func special(target):
	#Use special ability on target
	#End turn
	pass
	
func stance():
	#Open stance menu
	pass
	
func item():
	#If item available
		#Use item
		#End turn
	#Else
		#Display "no item" message
	pass
	
func flee():
	#Flee battle
	pass
