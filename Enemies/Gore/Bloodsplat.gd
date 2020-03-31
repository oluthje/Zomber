extends Sprite

onready var removal_timer = get_node("RemovalTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_up_removal()

func set_up_removal():
	randomize()
	var rand_time = rand_range(25, 35)
	removal_timer.set_wait_time(rand_time)
	removal_timer.start()

func _on_Timer_timeout():
	$AnimationPlayer.play("fadeout")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
