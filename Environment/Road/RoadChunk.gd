extends Node2D

var Stone = preload("res://Environment/Stone.tscn")
var FenceGate = preload("res://Environment/Road/FenceGate.tscn")
var Fence = preload("res://Environment/Road/Fence.tscn")
var House1 = preload("res://Environment/Road/Houses/House.tscn")
var House2 = preload("res://Environment/Road/Houses/House2.tscn")
var House3 = preload("res://Environment/Road/Houses/House3.tscn")

onready var road_chunk_size = get_parent().get_parent().road_chunk_size
var chunk_pos
var stone_positions = []
var curved = false

var house_poses = []

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
#	spawn_stones_by_positions(stone_positions)
	
func spawn_check_point():
	# Spawn fencegate
	var y_pos = road_chunk_size/2
	var gate = FenceGate.instance()
	get_node("Checkpoint").add_child(gate)
	gate.set_global_position(get_global_position() + Vector2(float(road_chunk_size)/float(2), y_pos))
	
	# Spawn fence
	for x in range(road_chunk_size/32):
		var mid_x = (road_chunk_size/32)/2
		if not [mid_x - 1, mid_x, mid_x + 1].has(x):
			var fence = Fence.instance()
			get_node("Checkpoint").add_child(fence)
			fence.set_global_position(get_global_position() + Vector2(x * 32, y_pos))
			
	# Spawn houses
	var house_offset_pos = Vector2(32 * 2, 32 * 4)
	var extra_offset = Vector2(0, 0)
	var spacing = 6
	for x in range(4):
		if x >= 2:
			extra_offset = house_offset_pos + Vector2(32 * 3, -96)
		for y in range(2):
			house_poses.append(Vector2(x * 32 * spacing, y * 32 * spacing) + house_offset_pos + extra_offset)
		
	for pos in house_poses:
		spawn_house(pos)
	spawn_house_loot()
	
	var rot = get_node("Road").get_rotation_degrees()
	get_node("Checkpoint").set_rotation_degrees(rot - 90)

func spawn_house(pos):
	randomize()
	var rand_rot = int(round(rand_range(0, 2)))
	var rot = rand_rot * 90
	
	randomize()
	var house
	var rand_house_num = int(round(rand_range(0, 2)))
	
	match rand_house_num:
		0:
			house = House1.instance()
		1:
			house = House2.instance()
		2:
			house = House3.instance()
	
	get_node("Checkpoint/Houses").add_child(house)
	house.set_global_position(get_global_position() + pos)
	rotate_house(house, rot)

func rotate_house(house_node, rot):
	var pos = house_node.get_global_position()
	match rot:
		90:
			house_node.set_global_position(pos + Vector2(64, -64))
			house_node.set_rotation_degrees(90)
		180:
			house_node.set_global_position(pos + Vector2(64, 64))
			house_node.set_rotation_degrees(180)
		270:
			house_node.set_global_position(pos + Vector2(-64, 64))
			house_node.set_rotation_degrees(270)
			
func spawn_house_loot():
	var houses = get_node("Checkpoint/Houses").get_children()
	var available_house_indices = []
	var spawned_gatekey = false
	
	for index in range(houses.size()):
		available_house_indices.append(index)
	
	# Two random houses open with key
	for i in range(2):
		randomize()
		var rand_index = int(rand_range(0, available_house_indices.size()))
		var index = available_house_indices[rand_index]
		houses[index].spawn_key = true
		houses[index].spawn_loot()
		available_house_indices.remove(rand_index)
	
	# Two random houses locked, only one has gatekey in them
	for i in range(2):
		randomize()
		var rand_index = int(rand_range(0, available_house_indices.size()))
		var index = available_house_indices[rand_index]
		if not spawned_gatekey:
			spawned_gatekey = true
			houses[index].spawn_gatekey = true
		houses[index].locked = true
		houses[index].spawn_loot()
		available_house_indices.remove(rand_index)
	
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
