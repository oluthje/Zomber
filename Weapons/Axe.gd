extends "res://Weapons/MeleeParent.gd"

func _ready():
	# Gun information
	hit_cooldown = 60 # Amount of time between each shot
	automatic = false
	damage = 15
	attack_speed = 2.5
	
	# Screen shake variables
	duration = 0.2
	frequency = 15
	amplitude = 4
	priority = 0
	
	._ready()

func _on_AnimationPlayer_animation_finished(anim_name):
	swing_finished()

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
