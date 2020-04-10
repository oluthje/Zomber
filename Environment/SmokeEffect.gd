extends Sprite

func _ready():
	$AnimationPlayer.set_speed_scale(1.5)
	$AnimationPlayer.play("smoke")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
