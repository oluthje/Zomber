extends "res://Weapons/GunParent.gd"

func _ready():
	# Shoot variables
	shot_cooldown = 5
	loaded_ammo = 8
	reload_amount = 8
	automatic = false
	dispersion = 15
	bullet_speed = 800
	bullet_damage = 15
	release_bullet_casing = true
	shoot_sound = Item.PISTOL_SHOT
	
	# Anim
	reload_anim_speed = .6
	
	# Screen shake
	duration = 0.05
	frequency = 35
	amplitude = 4
	priority = 0
	
	._ready()

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_reloading:
		reload_code()
