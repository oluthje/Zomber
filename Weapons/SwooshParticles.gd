extends Particles2D

func set_up(time):
	var timer = get_node("Timer")
	timer.set_wait_time(time)

func _on_Timer_timeout():
	queue_free()
