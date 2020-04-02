extends "res://Weapons/GunParent.gd"

var bullets_in_shot = 5
var bullet_speed_variation = 0.75

func _ready():
	# Shoot variables
	shot_cooldown = 25
	loaded_ammo = 2
	reload_amount = 2
	automatic = false
	dispersion = 30
	bullet_speed = 300
	bullet_damage = 15
	reload_anim_speed = 0.5
	
	# Screen shake variables
	duration = 0.1
	frequency = 30
	amplitude = 20
	priority = 0
	
	._ready()

func spawn_bullet():
	for i in range(bullets_in_shot):
		var bullet = Bullet.instance()
		bullet.set_global_position(get_node("BulletPos").global_position)
		bullet.set_up(get_global_rotation() + get_added_dispersion(), bullet_speed + get_bullet_speed_variation(), bullet_damage, "player")
		get_parent().get_parent().get_parent().add_child(bullet)
	
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

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_reloading:
		reload_code()
