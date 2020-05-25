extends Node2D

var time = 0

func _ready():
	var timer = get_node("Timer")
	timer.set_wait_time(time)
	timer.start()

func setup(sound_effect, life_time):
	time = life_time
	
	setup_sound(sound_effect)

func setup_sound(sound_effect):
	var sfx = sound_effect
	if sfx == Item.STONE_BREAK:
		randomize()
		var rand_num = rand_range(0.8, 1.2)
		get_node(sfx).pitch_scale = rand_num
	elif sfx == Item.STONE_HIT:
		randomize()
		var rand_num = rand_range(0.7, 1)
		get_node(sfx).pitch_scale = rand_num
	elif sfx == Item.ZOMBIE_SOUND:
		randomize()
		var rand_num = rand_range(1, 4)
		sfx += str(int(rand_num))
	
	get_node(sfx).play()

func _on_Timer_timeout():
	queue_free()
