extends KinematicBody2D

var PlayerCamera = preload("res://Camera2D.tscn")

var speed = 55
var friction = 0.05
var acceleration = 0.5
var velocity = Vector2.ZERO

var moving = true

func _ready():
	velocity = Vector2(-250, 0).rotated(get_global_rotation() + deg2rad(90))

func _physics_process(delta):
	if moving:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		velocity = move_and_slide(velocity)

func set_up(corpse):
	if corpse == "zombie":
		$AnimatedSprite.play("zombie")
	if corpse == "player":
		var camera = PlayerCamera.instance()
		add_child(camera)
		$AnimatedSprite.play("zombie")
		
	randomly_flip()

func randomly_flip():
	var rand_num = rand_range(0, 1)
	if rand_num == 0:
		$AnimatedSprite.set_flip_h(false)
	else:
		$AnimatedSprite.set_flip_h(true)
