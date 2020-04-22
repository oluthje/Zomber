extends Node2D

var selected_option = false

func _ready():
	$AnimationPlayer.set_speed_scale(0.75)
	$AnimationPlayer.play("enter")

func _on_PlayButton_pressed():
	if not selected_option:
		selected_option = true
		$AnimationPlayer.play("exit")
		get_tree().paused = false
		get_parent().respawn_game_node()

func _on_StatsButton_pressed():
	pass

func _on_QuitGameButton_pressed():
	if not selected_option:
		selected_option = true
		get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		queue_free()
