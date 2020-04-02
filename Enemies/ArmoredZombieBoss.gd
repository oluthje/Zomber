extends "res://Enemies/EnemyParent.gd"

var Bullet = preload("res://Weapons/Bullet.tscn")

var can_be_stunned = true
var walking_time = 2.5
var attack_time = 4
onready var walking_timer = get_node("WalkingSequenceTimer")
onready var attack_timer = get_node("AttackSequenceTimer")

# Bullet
var bullets_in_shot = 5
var bullet_damage = 10
var bullet_speed = 90
var dispersion = 20
var bullet_speed_variation = 0.50

func _ready():
	speed = 75
	min_distance = 50
	stun_time = 0.5
	health = 450
	can_move = true
	knock_back_amount = .2
	
	# Anim speeds
	walk_anim_speed = 1
	attack_anim_speed = 1
	
	stun_timer = get_node("StunTimer")
	stun_timer.set_wait_time(stun_time)
	
	walking_timer.set_wait_time(walking_time)
	walking_timer.start()

func spawn_bullet_spray():
	var bullet_pos_node = get_node("BulletPos")
	bullet_pos_node.set_position(Vector2(bullet_pos_node.get_position().x, -bullet_pos_node.get_position().y))
	for i in range(bullets_in_shot):
		var bullet = Bullet.instance()
		bullet.set_global_position(get_node("BulletPos").global_position)
		bullet.set_up(get_global_rotation() + get_added_dispersion(), bullet_speed + get_bullet_speed_variation(), bullet_damage, "enemy")
		get_parent().add_child(bullet)
	
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
	attack_timer.set_wait_time(attack_time)
	attack_timer.start()
	
func _on_AttackSequenceTimer_timeout():
	state = WALKING
	can_move = true
	walking_timer.set_wait_time(walking_time)
	walking_timer.start()

func _on_Timer_timeout():
	if can_be_stunned:
		stun_timer.set_wait_time(stun_time)
		stun_timer.start()
		#can_move = true
