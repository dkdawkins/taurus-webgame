extends KinematicBody2D

enum Facing {LEFT, RIGHT, UP, DOWN}

export var speed = 5.0
export var tileSize = 64.000

onready var sprite = $AnimatedSprite

var direction = Vector2() #(0,0), (1,0), (-1,0), (0,1), (0,-1)
var counter = 0.0
var facing = Facing.DOWN
var moving = false


func _process(delta):
	get_action()
	if not moving:
		set_direction()
	elif direction != Vector2():
		move(delta)
	else:
		moving = false

func set_direction():
	direction = get_direction()
	animate()
	if direction != Vector2():
		set_facing()
		moving = true

func get_direction():
	var x = 0
	var y = 0
	if direction.y == 0:
		x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if direction.x == 0 and x == 0:
		y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return Vector2(x, y)

func set_facing():
	if direction.x > 0:
		facing = Facing.RIGHT
	elif direction.x < 0:
		facing = Facing.LEFT
	elif direction.y > 0:
		facing = Facing.DOWN
	else:
		facing = Facing.UP

func get_action():
	if Input.is_action_just_pressed("ui_select"):
		var collision = null
		#Check if there is an object/obstacle in front of the player
		match facing:
			Facing.LEFT:
				collision = move_and_collide((Vector2(-1,0)*tileSize), true, true, true)
			Facing.RIGHT:
				collision = move_and_collide((Vector2(1,0)*tileSize), true, true, true)
			Facing.UP:
				collision = move_and_collide((Vector2(0,-1)*tileSize), true, true, true)
			_:
				collision = move_and_collide((Vector2(0,1)*tileSize), true, true, true)
		if collision != null:
			print(collision.collider.name)

func move(delta):
	counter += delta * speed
	move_and_collide((direction*tileSize*(delta*speed)))
	position = position.round()
	if counter >= 1.0:
		counter = 0.0
		if get_direction() != direction:
			moving = false

func animate():
	if direction != Vector2():
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
