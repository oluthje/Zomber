extends Particles2D

func _ready():
	set_emitting(true)

func _on_Timer_timeout():
	queue_free()
