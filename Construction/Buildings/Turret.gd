extends StaticBody2D

var Bullet = preload("res://Weapons/Bullet.tscn")
var ShotFlash = preload("res://Weapons/GunshotParticles.tscn")

var delta_num = 0

# Gun info
var shot_cooldown = 0.5
var can_shoot = true
var dispersion = 10
var bullet_speed = 650
var bullet_damage = 15

# Rotation info
var angular_speed = 2.5
var target_body
var has_target = false

# Idle movement
var move_idly = true
var turn_idly = true
var idle_turn_time = 2

func _physics_process(delta):
	delta_num = delta
	move()
			
func move():
	if not has_target:
		if get_target():
			target_body = get_target()
			has_target = true
		else:
			move_idly()
	else:
		if not is_instance_valid(target_body):
			has_target = false
			return
		rotate_towards_pos(target_body.get_global_position())
		if can_shoot and target_within_range():
			shoot()

func shoot():
	spawn_bullet()
	spawn_shot_flash()
	can_shoot = false
	$AnimationPlayer.play("recoil")
	$ShotCooldownTimer.set_wait_time(shot_cooldown)
	$ShotCooldownTimer.start()

func move_idly():
	var idle_timer = get_node("IdleTimer")
	if move_idly:
		idle_timer.set_wait_time(idle_turn_time)
		idle_timer.start()
		move_idly = false
	if turn_idly:
		var num = 1
#		randomize()
#		var rand_num = rand_range(0, 100)
#		if rand_num > 50:
#			num = -1
		rotate((num*angular_speed/2)*delta_num)

func get_target():
	var enemies_in_range = []
	var target
	
	if not len(get_node("Area2D").get_overlapping_bodies()) > 0:
		return null
	for body in get_node("Area2D").get_overlapping_bodies():
		if body.is_in_group("enemies"):
			enemies_in_range.append(body)
	if not len(enemies_in_range) > 0:
		return null
	
	target = enemies_in_range[0]
	for enemy in enemies_in_range:
		if get_distance_to_pos(enemy.get_global_position()) < get_distance_to_pos(target.get_global_position()):
			target = enemy
	
	return target
	
func target_within_range():
	var degree_range = 10
	if abs(rad2deg(get_rotation_to_pos(target_body.get_global_position()))) <= degree_range:
		return true
	return false

func get_distance_to_pos(pos):
	return get_global_position().distance_to(pos)

func rotate_towards_pos(pos):
	var angle = get_rotation_to_pos(pos)
	if angle < 0:
		rotate(-angular_speed*delta_num)
	elif angle > 0:
		rotate(angular_speed*delta_num)

func get_rotation_to_pos(pos):
	var angle = get_angle_to(pos)
	return angle

func spawn_bullet():
	var bullet = Bullet.instance()
	bullet.set_global_position(get_node("BulletPos").global_position)
	bullet.set_up(get_global_rotation() + get_added_dispersion(), bullet_speed, bullet_damage, "player")
	get_parent().add_child(bullet)

func get_added_dispersion():
	if dispersion > 0:
		randomize()
		var added_bullet_rot = rand_range(0, dispersion/2)
		randomize()
		var rand_num = rand_range(0, 100)
		if rand_num > 50:
			added_bullet_rot = added_bullet_rot * -1
		return deg2rad(added_bullet_rot)
	else:
		return 0
		
func spawn_shot_flash():
	var shot_flash = ShotFlash.instance()
	shot_flash.set_position(get_node("BulletPos").get_position())
	add_child(shot_flash)

func _on_ShotCooldownTimer_timeout():
	can_shoot = true

func _on_IdleTimer_timeout():
	move_idly = true
	if turn_idly:
		turn_idly = false
	else:
		turn_idly = true

func _on_Area2D_body_exited(body):
	if body == target_body:
		target_body = null
