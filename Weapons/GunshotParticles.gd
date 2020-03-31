extends Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	set_emitting(true)

func _on_Timer_timeout():
	queue_free()
