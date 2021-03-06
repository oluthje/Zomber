extends "res://Enemies/EnemyParent.gd"

func _ready():
	speed = 135
	angular_speed = 4
	min_distance = 50
	stun_time = 0.5
	health = 15
	can_move = true
	knock_back_amount = 2.5
	
	stun_timer = get_node("Timer")
	stun_timer.set_wait_time(stun_time)
	
	has_melee_attack = true
	melee_attack_distance = 24
	
	._ready()

func _on_Timer_timeout():
	stun_timer.set_wait_time(stun_time)
	stun_timer.start()
	can_move = true

func _on_PathfindingTimer_timeout():
	update_path = true
	update_if_move_to_player()
