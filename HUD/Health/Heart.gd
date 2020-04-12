extends Sprite

var VERSION = ""

func setup(version):
	VERSION = version
	if version == "half":
		$AnimationPlayer.play("half")
	else:
		$AnimationPlayer.play("full")

func lose_heart():
	if VERSION == "full":
		print("lost full")
		$AnimationPlayer.play("lose_full_heart")
		VERSION = "half"
	elif VERSION == "half":
		print("lost half")
		$AnimationPlayer.play("lose_half_heart")

func spawn_blood_particles():
	$Particles2D.restart()
	$Particles2D.set_emitting(true)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "lose_half_heart":
		queue_free()
