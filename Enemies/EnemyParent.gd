extends KinematicBody2D

var BloodSplatter = preload("res://Enemies/Gore/Bloodsplatter.tscn")
var BloodSplat = preload("res://Enemies/Gore/Bloodsplat.tscn")
var Corpse = preload("res://Enemies/Gore/Corpse.tscn")

var player_pos = Vector2()

# Movement
var speed = 115
var angular_speed = 1
var friction = 0.18
var acceleration = 0.5
var velocity = Vector2.ZERO
var knock_back_amount = 3
var knock_back_num = 0
var knock_back_dir = 0
var can_move = true
var can_be_stunned = true
var stun_timer
var stun_time = 0.1
var knocked_back = false

# Animation
var state = "walking"
var ATTACKING = "attacking"
var WALKING = "walking"
var walk_anim_speed = 1
var attack_anim_speed = 1

var min_distance = 50
var health = 35
var has_died = false
var delta_num = 0

# Pathfinding
var path_to_player = []
var next_pos = Vector2()
var update_path = true
var time_to_path_update = 1.5
var has_started_pathupdate_timer = false
var last_tilemap_pos = Vector2()

func _ready():
	pass

func _physics_process(delta):
	delta_num = delta
	pathfindng_move_to_player()

func pathfindng_move_to_player():
#	if move_directly_to_player():
#		move_to_player()
#		#$PathfindingTimer.set_wait_time(update_path_time)
#		#$PathfindingTimer.start()
#		#update_path = false
#		return

	player_pos = get_player_pos()
	var input_velocity = Vector2.ZERO
	input_velocity = (next_pos - get_global_position()).normalized()
	input_velocity = input_velocity.normalized() * speed
	
	if input_velocity.length() > 0 and can_move and not knocked_back:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	elif knocked_back:
		input_velocity = Vector2(-200, 0).rotated(knock_back_dir)
		if knock_back_num <= 0.5:
			knocked_back = false
		input_velocity = -input_velocity
		input_velocity = input_velocity.linear_interpolate(Vector2.ZERO, friction)
		velocity = (input_velocity.normalized() * speed * knock_back_num)
		knock_back_num -= 0.25
	else:
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)
	
	play_animations()
	rotate_towards_pos(next_pos)
	update_pathing()

func move_directly_to_player():
	var raycast = get_node("RayCast2D")
	raycast.set_rotation(get_rotation_to_pos(player_pos) - deg2rad(90))
	if raycast.is_colliding():
		if not "Stone" in raycast.get_collider().name:
			return true
	return false

func update_pathing():
	if not path_to_player or len(path_to_player) == 1 or should_update_path() or update_path:
		update_path = false
		path_to_player = get_path_to_player()
		path_to_player.remove(0)
		if len(path_to_player) > 0:
			next_pos = path_to_player[0]
		
	if arrived_at_next_point():
		path_to_player = get_path_to_player()
		path_to_player.remove(0)
		if len(path_to_player) == 0:
			can_move = false
			return
		can_move = true
		next_pos = path_to_player[0]
		
func should_update_path():
	var tilemap = get_parent().get_node("TileMap")
	
	# If self has not moved for a period of time
	var tilemap_pos = tilemap.world_to_map(get_global_position())
	if tilemap_pos == last_tilemap_pos and not has_started_pathupdate_timer:
		has_started_pathupdate_timer = true
		$PathfindingTimer.set_wait_time(time_to_path_update)
		$PathfindingTimer.start()
	else:
		has_started_pathupdate_timer = false
		$PathfindingTimer.stop()
	last_tilemap_pos = tilemap_pos
	
	if tilemap_pos != last_tilemap_pos:
		print("new tile")
	
	# If player has moved
	var last_pos_in_path = path_to_player[len(path_to_player) - 1]
	if not tilemap.world_to_map(last_pos_in_path) == tilemap.world_to_map(player_pos):
		return true
	return false
		
func get_path_to_player():
	return get_parent().get_node("TileMap").find_path(get_global_position(), player_pos)

func rotate_towards_pos(pos):
	var angle = get_rotation_to_pos(pos)
	if angle < 0:
		rotate(-angular_speed*delta_num)
	elif angle > 0:
		rotate(angular_speed*delta_num)

func arrived_at_next_point():
	var arrive_distance = 4
	var distance_to_next_pos = get_global_position().distance_to(next_pos)
	if distance_to_next_pos <= arrive_distance:
		return true
	return false
	
var WhiteCircle = preload("res://Sprite.tscn")
func draw_path():
	var node = get_parent().get_node("PathNodes")

	if node.get_children().size() > 0:
		for child in node.get_children():
			child.queue_free()

	for pos in path_to_player:
		var circle = WhiteCircle.instance()
		circle.set_position(pos)
		node.add_child(circle)
	
func play_animations():
	match state:
		WALKING:
			if can_move:
				$AnimationPlayer.set_speed_scale(walk_anim_speed)
				$AnimationPlayer.play("walk")
			else:
				$AnimationPlayer.play("idle")
		ATTACKING:
			$AnimationPlayer.set_speed_scale(attack_anim_speed)
			$AnimationPlayer.play("attack")
	
func get_player_pos():
	var game_node
	for child in get_tree().get_root().get_node("Main").get_children():
		if "Game" in child.name:
			game_node = child
	
	return game_node.player_pos

func take_damage(damage, dir):
	health -= damage
	if can_be_stunned:
		can_move = false
	knocked_back = true
	knock_back_num = knock_back_amount
	knock_back_dir = dir
	spawn_blood_splat()
	if health <= 0 and not has_died:
		has_died = true
		spawn_blood_splatter()
		spawn_corpse()
		queue_free()
	
func get_rotation_to_pos(pos):
	var angle = get_angle_to(pos)
	return angle

func spawn_blood_splatter():
	var blood_splatter = BloodSplatter.instance()
	blood_splatter.set_rotation(get_global_rotation() - deg2rad(180))
	blood_splatter.set_global_position(get_global_position())
	get_parent().add_child(blood_splatter)

func spawn_blood_splat():
	randomize()
	var rand_rot = rand_range(0, 360)
	var blood_splat = BloodSplat.instance()
	blood_splat.set_rotation(deg2rad(rand_rot))
	blood_splat.set_global_position(get_global_position())
	get_parent().add_child(blood_splat)

func spawn_corpse():
	var corpse = Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(knock_back_dir + deg2rad(90))
	corpse.set_up("zombie")
	get_parent().add_child(corpse)
	
func move_to_player():
	player_pos = get_player_pos()
	var input_velocity = Vector2.ZERO
	var rot_to_player = get_rotation_to_pos(player_pos)
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
	rotate_towards_pos(player_pos)
	velocity = move_and_slide(velocity)
	
