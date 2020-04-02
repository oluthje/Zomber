extends Node2D

var TreeNode = preload("res://Environment/Tree.tscn")

var player_pos = Vector2()
var using_menu = false

# Game settings
var spawn_enemies = true
var map_size = Vector2(36, 18)

func _ready():
	spawn_trees_randomly()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
# Handy methods
func get_rotation_to_node(start_pos, end_pos):
	var angle = start_pos.angle_to_point(end_pos)
	return angle

func spawn_trees_randomly():
	for x in range(map_size.x):
		for y in range(map_size.y):
			if should_spawn_tree():
				var tree = TreeNode.instance()
				tree.set_global_position(Vector2(x*32, y*32))
				add_child(tree)

func should_spawn_tree():
	var spawn_chance = 5
	randomize()
	var rand_num = rand_range(0, 100)
	if rand_num <= spawn_chance:
		return true
	return false
