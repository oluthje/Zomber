extends Node2D

var Stone = preload("res://Environment/Stone.tscn")

var chunk_pos
var stone_positions = []
var curved = false

func _ready():
	var label = Label.new()
	label.set_text("chunk_pos: " + str(chunk_pos))
	add_child(label)
	
	if "Curved" in name:
		curved = true
	
	if stone_positions.empty():
		stone_positions = get_perlin_noise_terrain()
	spawn_stones_by_positions(stone_positions)
	
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
