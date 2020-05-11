extends Node2D

func setup(sound_effect, life_time):
	var timer = get_node("Timer")
	timer.set_wait_time(life_time)
	timer.start()
	
	get_node(sound_effect).play()

func _on_Timer_timeout():
	queue_free()
