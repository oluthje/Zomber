extends "res://Enemies/EnemyParent.gd"

var Bullet = preload("res://Weapons/Bullet.tscn")
var GroundHitParticles = preload("res://Enemies/Bosses/GroundHitParticles.tscn")
var Crate = preload("res://Loot/Crate.tscn")

var walking_time = 2.5
var attack_time = 5
onready var walking_timer = get_node("WalkingSequenceTimer")
onready var attack_timer = get_node("AttackSequenceTimer")

# Bullet
var bullets_in_shot = 5
var bullet_damage = 10
var bullet_speed = 90
var dispersion = 20
var bullet_speed_variation = 0.50

var total_health = 0
var total_armor = 3

func _ready():
	speed = 75
	angular_speed = 1.5
	min_distance = 50
	stun_time = 0.5
	health = 650
	total_health = health
	can_move = true
	can_be_stunned = false
	knock_back_amount = 0.2
	is_boss = true
	
	# Anim speeds
	walk_anim_speed = 1
	attack_anim_speed = 1
	
	stun_timer = get_node("StunTimer")
	stun_timer.set_wait_time(stun_time)
	
	walking_timer.set_wait_time(walking_time)
	walking_timer.start()

func take_damage(damage, dir):
	health -= damage
	knocked_back = true
	knock_back_num = knock_back_amount
	knock_back_dir = dir
	check_for_armor_destruction()
	spawn_blood_splat()
	if health <= 0 and not has_died:
		has_died = true
		spawn_blood_splatter()
		spawn_corpse()
		spawn_crate()
		queue_free()

func spawn_crate():
	var crate = Crate.instance()
	crate.set_global_position(get_global_position())
	get_parent().add_child(crate)

func check_for_armor_destruction():
	var has_dropped_armor = false
	if health <= 0.25 * total_health and total_armor == 1 and not has_dropped_armor:
		drop_armor()
		has_dropped_armor = true
		total_armor -= 1
	if health <= 0.50 * total_health and total_armor == 2 and not has_dropped_armor:
		drop_armor()
		has_dropped_armor = true
		total_armor -= 1
	if health <= 0.75 * total_health and total_armor == 3 and not has_dropped_armor:
		drop_armor()
		has_dropped_armor = true
		total_armor -= 1

func drop_armor():
	randomize()
	var rand_armor_num = rand_range(0, get_node("Armor").get_children().size())
	var armor_pieces = []
	for child in get_node("Armor").get_children():
		armor_pieces.append(child)
	armor_pieces[rand_armor_num].queue_free()
	
	var corpse = Corpse.instance()
	corpse.set_global_position(get_global_position())
	corpse.set_rotation(get_global_rotation() - deg2rad(90))
	corpse.set_up("armor")
	get_parent().add_child(corpse)
	
func spawn_dirt_particles():
	var ground_hit_particles = GroundHitParticles.instance()
	ground_hit_particles.set_global_position($BulletPos.get_global_position())
	get_parent().add_child(ground_hit_particles)

func spawn_bullet_spray():
	print("bullet spray")
	var bullet_pos_node = get_node("BulletPos")
	bullet_pos_node.set_position(Vector2(bullet_pos_node.get_position().x, -bullet_pos_node.get_position().y))
	for i in range(bullets_in_shot):
		var bullet = Bullet.instance()
		bullet.set_global_position(get_node("BulletPos").global_position)
		bullet.set_up(get_global_rotation() + get_added_dispersion(), bullet_speed + get_bullet_speed_variation(), bullet_damage, "enemy")
		get_parent().add_child(bullet)
		
	spawn_dirt_particles()
	
func get_added_dispersion():
	if dispersion > 0:
		randomize()
		var added_bullet_rot = rand_range(0, dispersion/2)
		randomize()
		var rand_num = rand_range(0, 100)
		if rand_num > 50:
			added_bullet_rot = -added_bullet_rot
		return deg2rad(added_bullet_rot)
	else:
		return 0

func get_bullet_speed_variation():
	randomize()
	var rand_speed = rand_range(0, bullet_speed * bullet_speed_variation)
	return rand_speed

func _on_WalkingSequenceTimer_timeout():
	state = ATTACKING
	can_move = false
	
	var distance_to_player = get_global_position().distance_to(get_player_pos())
	if distance_to_player <= 240:
		attack_timer.set_wait_time(attack_time)
		attack_timer.start()
	else:
		state = WALKING
		can_move = true
		walking_timer.set_wait_time(walking_time)
		walking_timer.start()
	
func _on_AttackSequenceTimer_timeout():
	state = WALKING
	can_move = true
	walking_timer.set_wait_time(walking_time)
	walking_timer.start()

func _on_Timer_timeout():
	if can_be_stunned:
		stun_timer.set_wait_time(stun_time)
		stun_timer.start()

func _on_PathfindingTimer_timeout():
	update_path = true
	update_if_move_to_player()
