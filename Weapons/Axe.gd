extends "res://Weapons/MeleeParent.gd"

func _ready():
	# Gun information
	swing_cooldown = 0.5 # Amount of time between each shot
	swoosh_time = 0.2
	automatic = false
	damage = 50
	attack_speed = 3
	
	# Screen shake variables
	duration = 0.2
	frequency = 15
	amplitude = 4
	priority = 0
	
	._ready()

func _on_AnimationPlayer_animation_finished(anim_name):
	swing_anim_finished()
	
func _on_CoolDownTimer_timeout():
	swing_cooldown_finished()

func _on_Area2D_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
	elif "Tree" in body.name:
		body.take_damage()
