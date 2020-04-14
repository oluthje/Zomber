extends "res://Weapons/GunParent.gd"

func _ready():
	# Shoot variables
	shot_cooldown = 7.5
	loaded_ammo = 30
	reload_amount = 30
	automatic = true
	dispersion = 15
	bullet_speed = 800
	bullet_damage = 15
	release_bullet_casing = true
	
	# Anim
	reload_anim_speed = 0.35
	shoot_anim_speed = 1.75
	
	# Screen shake
	duration = 0.05
	frequency = 40
	amplitude = 4
	priority = 0
	
	._ready()

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_reloading:
		reload_code()
