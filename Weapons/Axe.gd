extends "res://Weapons/MeleeParent.gd"

func _ready():
	# Gun information
	swing_cooldown = 0.5 # Amount of time between each shot
	swoosh_time = 0.2
	automatic = true
	damage = 25
	attack_anim_speed = 2
	
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
	if not has_hit:
		if body.is_in_group("enemies"):
			var dir = get_parent().get_parent().get_global_rotation()
			body.take_damage(damage, dir)
			has_hit = true
		elif "Tree" in body.name:
			body.take_damage(true)
			has_hit = true

func _on_Area2D_area_entered(area):
	if not has_hit:
		if "RiotShield" in area.name:
			has_hit = true
