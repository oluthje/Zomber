extends Sprite

func _physics_process(delta):
	set_global_position(get_global_mouse_position())
