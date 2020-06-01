extends Node2D

var Stone = preload("res://Environment/Stone.tscn")
var FenceGate = preload("res://Environment/Road/FenceGate.tscn")
var Fence = preload("res://Environment/Road/Fence.tscn")

onready var road_chunk_size = get_parent().get_parent().road_chunk_size
var chunk_pos
var stone_positions = []
var curved = false

func _ready():
	var label = Label.new()
	label.set_text("chunk_pos: " + str(chunk_pos))
	add_child(label)
	
	if "Curved" in name:
		curved = true
	else:
		spawn_check_point()
	
	if stone_positions.empty():
		stone_positions = get_perlin_noise_terrain()
	spawn_stones_by_positions(stone_positions)
	
func spawn_check_point():
	var gate = FenceGate.instance()
	var y_pos = 128#road_chunk_size/2
	get_node("Checkpoint").add_child(gate)
	gate.set_global_position(get_global_position() + Vector2(float(road_chunk_size)/float(2), y_pos))
	
	for x in range(road_chunk_size/32):
		var mid_x = (road_chunk_size/32)/2
		if not [mid_x - 1, mid_x, mid_x + 1].has(x):
			var fence = Fence.instance()
			get_node("Checkpoint").add_child(fence)
			fence.set_global_position(get_global_position() + Vector2(x * 32, y_pos))
	
	
#	var rot = get_node("Road").get_rotation_degrees()
#	get_node("Checkpoint").set_rotation_degrees(rot)
	
func get_perlin_noise_terrain():
	var rot = int(get_node("Road").get_rotation_degrees())
	return get_parent().get_parent().get_node("RoadPerlinNoiseTest").get_stone_positions_from_noise(chunk_pos, curved, rot)

func set_road_rotation(rot):
	get_node("Road").set_rotation(deg2rad(rot))

func spawn_stones_by_positions(positions):
	for pos in positions:
		var stone = Stone.instance()
		stone.set_position(pos)
		add_child(stone)
