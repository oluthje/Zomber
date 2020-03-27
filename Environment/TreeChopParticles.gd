extends Particles2D

onready var timer = get_node("Timer")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_emitting(true)
	timer.set_wait_time(1)
	timer.start()

func _on_Timer_timeout():
	queue_free()
