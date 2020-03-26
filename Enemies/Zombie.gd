extends KinematicBody2D

var BloodSplatter = preload("res://Enemies/Gore/Bloodsplatter.tscn")
var BloodSplat = preload("res://Enemies/Gore/Bloodsplat.tscn")
var Corpse = preload("res://Enemies/Gore/Corpse.tscn")

onready var stun_timer = get_node("Timer")

var player_pos = Vector2()
var velocity = Vector2()

var stun_time = 0.1

var speed = 125
var min_distance = 50
var health = 35
var can_move = true

func _ready():
	stun_timer.set_wait_time(stun_time)

func _physics_process(delta):
	move()
	rotate_towards_player()

func rotate_towards_player():
	rotate(get_rotation_to_player() + deg2rad(90))

func move():
	player_pos = get_player_pos()
	var distance_to_player = get_global_position().distance_to(player_pos)
	if can_move and distance_to_player >= 20:
		velocity = Vector2()
		velocity = (player_pos - get_global_position()).normalized()
		move_and_slide(velocity * speed)
		velocity = velocity.normalized() * speed
		
func get_player_pos():
	var game_node
	for child in get_tree().get_root().get_node("Main").get_children():
		if "Game" in child.name:
			game_node = child
	
	return game_node.player_pos

func take_damage(damage):
	health -= damage
	can_move = false
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
	blood_splatter.set_rotation(get_global_rotation() + deg2rad(90))
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
	corpse.set_rotation(get_global_rotation() - deg2rad(180))
	corpse.set_up("zonbie")
	get_parent().add_child(corpse)

func _on_Timer_timeout():
	stun_timer.set_wait_time(stun_time)
	stun_timer.start()
	can_move = true
