extends Camera2D

var max_offset = 350
var min_offset = 50
export var increment = 32

onready var main = get_tree().get_root().get_node("Main")
onready var cursor = get_parent().get_node("CanvasLayer").get_node("Cursor")
onready var player_pos = get_tree().get_root().get_node("Main").player_pos

func _ready():
	set_limits()

var zoom_in = true
func _physics_process(delta):
	main.player_pos = main.player_pos
	align_camera_to_mouse()

func align_camera_to_mouse():
	set_global_position(main.player_pos.linear_interpolate(get_global_mouse_position(), 0.25))

func get_clamped_distance_to_cursor():
	var difference = main.player_pos - cursor.get_global_position()
	difference = difference.clamped(max_offset)
	return difference

func get_distance_to_player_from_cursor():
	return player_pos.distance_to(get_global_mouse_position())

func set_limits():
	if main.current_level == levels.THE_ROAD:
		pass
	else:
		var map_size = get_parent().map_size
		limit_top = 0
		limit_right = map_size.x * increment
		limit_bottom = map_size.y * increment
		limit_left = 0
