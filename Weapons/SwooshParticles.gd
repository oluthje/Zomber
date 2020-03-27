extends Particles2D

func set_up(time):
	var timer = get_node("Timer")
	print(time)
	timer.set_wait_time(time)

func _on_Timer_timeout():
	print("timeout")
	queue_free()
