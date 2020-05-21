extends "res://Weapons/GunParent.gd"

func _ready():
	# Shoot variables
	shot_cooldown = 68
	loaded_ammo = 5
	reload_amount = 5
	automatic = false
	dispersion = 2.5
	bullet_speed = 800
	bullet_damage = 50
	release_bullet_casing = true
	shoot_sound = Item.PISTOL_SHOT
	
	# Anim
	reload_anim_speed = 1
	shoot_anim_speed = 1.5
	
	# Screen shake
	duration = 0.1
	frequency = 35
	amplitude = 5
	priority = 0
	
	._ready()

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_reloading:
		reload_code()
