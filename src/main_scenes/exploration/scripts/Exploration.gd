extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.connect("object_selected", self, "_on_object_selected")

#TODO: implement me
func initialize():
	pass

#TODO: implement special functionality for different object types
func _on_object_selected(object):
	for dialog in object.dialogs:
		print(dialog)
	match object.type:
		object.ObjectType.ITEM:
			pass
		object.ObjectType.CHECKPOINT:
			pass
		object.ObjectType.ENEMY:
			pass
		_:
			pass
