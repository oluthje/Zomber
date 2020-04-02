extends "res://Enemies/EnemyParent.gd"

func _ready():
	speed = 90
	min_distance = 50
	stun_time = 0.5
	health = 35
	can_move = true
	knock_back_amount = 2.5
	
	stun_timer = get_node("Timer")
	stun_timer.set_wait_time(stun_time)

func _on_Timer_timeout():
	stun_timer.set_wait_time(stun_time)
	stun_timer.start()
	can_move = true
