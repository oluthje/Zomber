extends "res://Enemies/EnemyParent.gd"

var CARRYING = "carrying"
var lost_shield = false

func _ready():
	speed = 35
	angular_speed = 1
	min_distance = 50
	stun_time = 0.5
	health = 35
	can_move = true
	knock_back_amount = 1.5
	
	# Anim speeds
	walk_anim_speed = 0.5
	attack_anim_speed = 1
	
	stun_timer = get_node("Timer")
	stun_timer.set_wait_time(stun_time)

func play_animations():
	if not lost_shield:
		state = CARRYING
	else:
		state = WALKING
	match state:
		WALKING:
			$AnimationPlayer.set_speed_scale(walk_anim_speed)
			$AnimationPlayer.play("walk")
		ATTACKING:
			$AnimationPlayer.set_speed_scale(attack_anim_speed)
			$AnimationPlayer.play("attack")
		CARRYING:
			$AnimationPlayer.play("carryshield")

func _on_Timer_timeout():
	stun_timer.set_wait_time(stun_time)
	stun_timer.start()
	can_move = true

func _on_PathfindingTimer_timeout():
	update_path = true
	update_if_move_to_player()
