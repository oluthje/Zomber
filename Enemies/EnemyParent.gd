extends KinematicBody2D

var BloodSplatter = preload("res://Enemies/Gore/Bloodsplatter.tscn")
var BloodSplat = preload("res://Enemies/Gore/Bloodsplat.tscn")
var Corpse = preload("res://Enemies/Gore/Corpse.tscn")

var player_pos = Vector2()

# Movement
var speed = 115
var friction = 0.18
var acceleration = 0.5
var velocity = Vector2.ZERO
var knock_back_amount = 3
var knock_back_num = 0

# Animation
var state = "walking"
var ATTACKING = "attacking"
var WALKING = "walking"
var walk_anim_speed = 1
var attack_anim_speed = 1

var min_distance = 50
var stun_time = 0.1
var health = 35
var can_move = true
var knocked_back = false

var stun_timer

func _physics_process(delta):
	move()
	rotate_towards_player()

func rotate_towards_player():
	rotate(get_rotation_to_player())

func move():
	player_pos = get_player_pos()
	var input_velocity = Vector2.ZERO
	var rot_to_player = get_rotation_to_player()
	var distance_to_player = get_global_position().distance_to(player_pos)
	input_velocity = (player_pos - get_global_position()).normalized()
	input_velocity = input_velocity.normalized() * speed
	
	if input_velocity.length() > 0 and can_move and not knocked_back and distance_to_player >= 20:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	elif knocked_back:
		if knock_back_num <= 0.5:
			knocked_back = false
		input_velocity = -input_velocity
		input_velocity = input_velocity.linear_interpolate(Vector2.ZERO, friction)
		velocity = (input_velocity.normalized() * speed * knock_back_num)
		knock_back_num -= 0.25
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	play_animations()
	velocity = move_and_slide(velocity)
	
func play_animations():
	match state:
		WALKING:
			$AnimationPlayer.set_speed_scale(walk_anim_speed)
			$AnimationPlayer.play("walk")
		ATTACKING:
			$AnimationPlayer.set_speed_scale(attack_anim_speed)
			$AnimationPlayer.play("attack")
	
func get_player_pos():
	var game_node
	for child in get_tree().get_root().get_node("Main").get_children():
		if "Game" in child.name:
			game_node = child
	
	return game_node.player_pos

func take_damage(damage):
	health -= damage
	can_move = false
	knocked_back = true
	knock_back_num = knock_back_amount
	spawn_blood_splat()
	if health <= 0:
		spawn_blood_splatter()
		spawn_corpse()
		queue_free()
	
func get_rotation_to_player():
	var angle = get_angle_to(player_pos)
	return angle

func spawn_blood_splatter():
	var blood_splatter = BloodSplatter.instance()
	blood_splatter.set_rotation(get_global_rotation() - deg2rad(180))
	blood_splatter.set_global_position(get_global_position())
	get_parent().add_child(blood_splatter)

func spawn_blood_splat():
	var blood_splat = BloodSplat.instance()
	
	randomize()
	var rand_rot = rand_range(0, 360)
	blood_splat.set_rotation(deg2rad(rand_rot))
	blood_splat.set_global_position(get_global_position())
	get_parent().add_child(blood_splat)

func spawn_corpse():
	var corpse = Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(get_global_rotation() - deg2rad(90))
	corpse.set_up("zombie")
	get_parent().add_child(corpse)
