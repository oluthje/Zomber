extends Node2D

var life_time = 0

func _ready():
	get_node("Timer").set_wait_time(life_time)
	get_node("Timer").start()

func setup(particle, time):
	get_node(particle).set_emitting(true)
	life_time = time

func _on_Timer_timeout():
	queue_free()
