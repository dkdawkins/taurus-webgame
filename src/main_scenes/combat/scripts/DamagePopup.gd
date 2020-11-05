extends Position2D

onready var label = get_node("Label")

var text = ""
var type = ""

var velocity = Vector2(0,0)
var timer = 0

func _ready():
	label.text = text
	match type:
		"Heal":
			label.set("custon_colors/font_color", Color("2eff27"))
		"Damage":
			label.set("custon_colors/font_color", Color(1, 1, 1))
	var movement = randi() % 100 - 50
	if randi() % 10 < 5:
		velocity = Vector2(movement, 50)
	else:
		velocity = Vector2(movement, -50)

func _process(delta):
	position -= velocity * delta
	timer += 1 * delta
	if timer >= 50 * delta:
		self.queue_free()
