extends Node2D

var option_selected = false

func _on_UnpauseButton_pressed():
	if not option_selected:
		option_selected = true
		get_parent().remove_pause_menu()

func _on_UnpauseButton2_pressed():
	if not option_selected:
		option_selected = true
		#get_parent().save_stats(get_parent().get_game_node().current_stats_dict)
		#print(get_parent().save_stats(get_parent().get_game_node().name))
		get_parent().delete_game_node()
		get_parent().spawn_main_menu()
		$AnimationPlayer.play("exit")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "exit":
		get_parent().pause_menu_exists = false
		queue_free()
