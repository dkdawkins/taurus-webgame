extends KinematicBody2D

export var speed = 5.0
export var tileSize = 64.000

onready var sprite = $AnimatedSprite

var direction = Vector2() #(0,0), (1,0), (0,1)
var counter = 0.0

var moving = false


func _process(delta):
	if not moving:
		set_direction()
	elif direction != Vector2():
		move(delta)
	else:
		moving = false

func set_direction():
	direction = get_direction()
	animate(direction)
	if direction.x != 0 or direction.y != 0:
		moving = true

func get_direction():
	var x = 0
	var y = 0
	if direction.y == 0:
		x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if direction.x == 0 and x == 0:
		y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return Vector2(x, y)

func move(delta):
	counter += delta * speed
	move_and_collide((direction*tileSize*(delta*speed)))
	position = position.round()
	if counter >= 1.0:
		counter = 0.0
		if get_direction() != direction:
			moving = false

func animate(direction):
	if direction.x != 0 or direction.y != 0:
		if direction.x > 0:
			sprite.flip_h = true
			sprite.play("walking_h")
		elif direction.x < 0:
			sprite.flip_h = false
			sprite.play("walking_h")
		elif direction.y > 0:
			sprite.play("walking_down")
		else:
			sprite.play("walking_up")
	else:
		sprite.play("default")
