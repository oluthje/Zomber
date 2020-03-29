extends Label

func _ready():
	$AnimationPlayer.play("Panning")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
