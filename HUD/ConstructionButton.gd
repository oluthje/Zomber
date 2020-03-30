extends Node2D

onready var auto_close_timer = get_node("AutoCloseTimer")

var BuildingButtons = preload("res://HUD/BuildingButtons.tscn")
var showing_buildings = false
var game_node

var time_before_auto_close = 10

func spawn_building_buttons():
	var buttons = BuildingButtons.instance()
	buttons.set_global_position(Vector2(456, 16))
	add_child(buttons)
	
	start_auto_close_timer()

func remove_buttons():
	for child in get_children():
		if "BuildingButtons" in child.name:
			child.hide_buttons()

func start_auto_close_timer():
	auto_close_timer.set_wait_time(time_before_auto_close)
	auto_close_timer.start()
	
func _on_TextureButton_pressed():
	if showing_buildings:
		remove_buttons()
		showing_buildings = false
	else:
		spawn_building_buttons()
		showing_buildings = true

func _on_TextureButton_mouse_entered():
	Item.using_menu = true

func _on_TextureButton_mouse_exited():
	Item.using_menu = false

func _on_AutoCloseTimer_timeout():
	remove_buttons()
	showing_buildings = false
