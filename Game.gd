extends Node2D

var player_pos = Vector2()

# Game settings
var spawn_enemies = false

# Handy methods
func get_rotation_to_node(start_pos, end_pos):
	var angle = start_pos.angle_to_point(end_pos)
	return angle
