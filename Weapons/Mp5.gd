extends "res://Weapons/GunParent.gd"

func _ready():
	# Shoot variables
	shot_cooldown = 3.2
	loaded_ammo = 30
	reload_amount = 30
	automatic = true
	dispersion = 30
	bullet_speed = 800
	bullet_damage = 10
	release_bullet_casing = true
	shoot_sound = Item.PISTOL_SHOT
	
	# Anim
	reload_anim_speed = 0.8
	shoot_anim_speed = 2
	
	# Screen shake
	duration = 0.05
	frequency = 25
	amplitude = 5
	priority = 0
	
	._ready()

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_reloading:
		reload_code()
