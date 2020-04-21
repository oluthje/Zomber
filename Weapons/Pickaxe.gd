extends "res://Weapons/MeleeParent.gd"

func _ready():
	swing_cooldown = 1 # Amount of time between each shot
	swoosh_time = 0.2
	automatic = true
	damage = 50
	
	attack_anim_speed = 1
	
	# Screen shake variables
	duration = 0.2
	frequency = 15
	amplitude = 4
	priority = 0
	
	._ready()
	
func swing():
	is_swinging = true
	$AnimationPlayer.set_speed_scale(attack_anim_speed)
	$AnimationPlayer.play("swingright")
		
	get_node("CoolDownTimer").set_wait_time(swing_cooldown)
	get_node("CoolDownTimer").start()

func _on_AnimationPlayer_animation_finished(anim_name):
	swing_anim_finished()

func _on_CoolDownTimer_timeout():
	swing_cooldown_finished()

func _on_Area2D_body_entered(body):
	if not has_hit:
		if body.is_in_group("enemies"):
			var dir = get_parent().get_parent().get_global_rotation()
			body.take_damage(damage/2, dir)
			has_hit = true
		elif "Tree" in body.name:
			body.take_damage(false)
			has_hit = true
		elif "Stone" in body.name:
			body.take_damage(damage)
			has_hit = true

func _on_Area2D_area_entered(area):
	if not has_hit:
		if "RiotShield" in area.name:
			has_hit = true
