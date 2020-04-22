extends Node2D

var option_selected = false

func _on_UnpauseButton_pressed():
	if not option_selected:
		option_selected = true
		get_parent().remove_pause_menu()

func _on_UnpauseButton2_pressed():
	if not option_selected:
		option_selected = true
		get_parent().pause_menu_exists = false
		get_parent().game_paused = false
		get_tree().paused = false
		get_parent().delete_game_node()
		get_parent().spawn_main_menu()
		$AnimationPlayer.play("exit")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		get_parent().pause_menu_exists = false
		queue_free()
