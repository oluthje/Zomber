extends KinematicBody2D

var PlayerCamera = preload("res://HUD/Camera2D.tscn")
onready var removal_timer = get_node("RemovalTimer")

var speed = 55
var friction = 0.05
var acceleration = 0.5
var velocity = Vector2.ZERO

var moving = true

func _ready():
	velocity = Vector2(-250, 0).rotated(get_global_rotation() + deg2rad(90))
	set_up_removal()

func _physics_process(delta):
	if moving:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
		velocity = move_and_slide(velocity)

func set_up(corpse):
	if corpse == "player":
		var camera = PlayerCamera.instance()
		add_child(camera)
		$AnimatedSprite.play("zombie")
	else:
		$AnimatedSprite.play(corpse)
		
	randomly_flip()
	
func set_up_removal():
	randomize()
	var rand_time = rand_range(25, 35)
	removal_timer.set_wait_time(rand_time)
	removal_timer.start()

func randomly_flip():
	var rand_num = rand_range(0, 1)
	if rand_num == 0:
		$AnimatedSprite.set_flip_h(false)
	else:
		$AnimatedSprite.set_flip_h(true)

func _on_RemovalTimer_timeout():
	$AnimationPlayer.play("fadeout")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
