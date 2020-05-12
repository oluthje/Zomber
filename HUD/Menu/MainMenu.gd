extends Node2D

var StatsMenu = preload("res://HUD/Menu/StatsMenu.tscn")

var selected_option = false
var button_pressed = ""

var driving_time = 3.5

func _ready():
	$AnimationPlayer.play("enter")

func spawn_stats_menu():
	var menu = StatsMenu.instance()
	add_child(menu)
	
func zoom_into_driving():
	$ZoomInPlayer.play("zoomin")
	get_node("Cursor").set_visible(false)
	
	var drive_timer = get_node("DriveTimer")
	drive_timer.set_wait_time(driving_time)
	drive_timer.start()
	
func enter_game():
	button_pressed = ""
	get_tree().paused = false
	get_parent().respawn_game_node()
	queue_free()

func _on_PlayButton_pressed():
	if not selected_option:
		zoom_into_driving()
		button_pressed = "playbutton"
		selected_option = true
		$AnimationPlayer.play("exit")

func _on_StatsButton_pressed():
	if not selected_option:
		button_pressed = "statsbutton"
		$AnimationPlayer.play("exit")

func _on_QuitGameButton_pressed():
	if not selected_option:
		selected_option = true
		get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name):
	if button_pressed == "playbutton":
		pass
	if button_pressed == "statsbutton":
		button_pressed = ""
		spawn_stats_menu()

func _on_DriveTimer_timeout():
	$ZoomInPlayer.play("black_out")
