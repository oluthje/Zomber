extends Camera2D

var max_offset = 350
var min_offset = 50

onready var cursor = get_parent().get_node("CanvasLayer").get_node("Cursor")
onready var player = get_parent().get_node("Player")

func _physics_process(delta):
	if is_instance_valid(player):
		align_camera_to_mouse()

func align_camera_to_mouse():
#	if get_distance_to_player_from_cursor() > min_offset and get_distance_to_player_from_cursor() < max_offset:
	set_global_position(player.get_global_position().linear_interpolate(get_global_mouse_position(), 0.25))
#	else:
#		set_global_position(get_global_position().linear_interpolate(player.get_global_position(), 0.10))

func get_clamped_distance_to_cursor():
	var difference = player.get_global_position() - cursor.get_global_position()
	difference = difference.clamped(max_offset)
	return difference

func get_distance_to_player_from_cursor():
	return player.get_global_position().distance_to(get_global_mouse_position())
