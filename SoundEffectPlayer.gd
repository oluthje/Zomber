extends Node2D

var time = 0

func _ready():
	var timer = get_node("Timer")
	timer.set_wait_time(time)
	timer.start()

func setup(sound_effect, life_time):
	time = life_time
	
	set_sound_pitch(sound_effect)
	get_node(sound_effect).play()

func set_sound_pitch(sound_effect):
	if sound_effect == Item.STONE_BREAK:
		randomize()
		var rand_num = rand_range(0.8, 1.2)
		get_node(sound_effect).pitch_scale = rand_num
	elif sound_effect == Item.STONE_HIT:
		randomize()
		var rand_num = rand_range(0.7, 1)
		get_node(sound_effect).pitch_scale = rand_num

func _on_Timer_timeout():
	queue_free()
