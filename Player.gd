extends KinematicBody2D

var Bullet = preload("res://Bullet.tscn")
var Corpse = preload("res://Corpse.tscn")

onready var timer = get_node("ShotDelay")


# Movement
var speed = 150
var friction = 0.18
var acceleration = 0.5
var velocity = Vector2.ZERO

# Gun variables
var shot_delay = 0.25

# Screen shake variables
var duration = 0.05
var frequency = 50
var amplitude = 6
var priority = 0

# Misc
var can_shoot = true

func _ready():
	timer.set_wait_time(shot_delay)

func _physics_process(delta):
	rotate(get_rotation_toward_mouse())
	get_input()
	
	get_parent().player_pos = get_global_position()
	
func get_rotation_toward_mouse():
	var mouse_pos = get_global_mouse_position()
	var angle = get_angle_to(mouse_pos)

	return angle + deg2rad(90)
	
func take_damage():
	spawn_corpse()
	queue_free()
	
func spawn_corpse():
	var corpse = Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(get_global_rotation() - deg2rad(180))
	corpse.set_up("player")
	get_parent().add_child(corpse)

func get_input():
	var input_velocity = Vector2.ZERO
	
	if Input.is_action_pressed('right'):
		input_velocity.x += 1
	if Input.is_action_pressed('left'):
		input_velocity.x -= 1
	if Input.is_action_pressed('down'):
		input_velocity.y += 1
	if Input.is_action_pressed('up'):
		input_velocity.y -= 1
	if Input.is_action_pressed("shoot"):
		shoot()
		
	input_velocity = input_velocity.normalized() * speed
	
	# If there's input, accelerate to the input velocity
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)

func shoot():
	if can_shoot:
		$AnimationPlayer.play("Shoot")
		spawn_bullet()
		shake_screen()
		timer.start()
		can_shoot = false
		
func shake_screen():
	get_node("Camera2D").get_node("ScreenShake").start(duration, frequency, amplitude, priority)
	
func spawn_bullet():
	var bullet = Bullet.instance()
	get_parent().add_child(bullet)
	bullet.set_global_position(get_node("BulletPos").get_global_position())
	bullet.set_up(rotation - deg2rad(90))
	
func _on_ShotDelay_timeout():
	can_shoot = true
	timer.set_wait_time(shot_delay)

func _on_Area2D_body_entered(body):
	if "Zombie" in body.name:
		take_damage()
