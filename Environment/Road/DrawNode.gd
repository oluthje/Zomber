extends Node2D

var draw = false

func _draw():
	if draw:
		var road_chunk_size = get_parent().road_chunk_size
		var house_poses = get_parent().house_poses
		for y in range(road_chunk_size/2/32):
			draw_line(Vector2(0, y * 32), Vector2(road_chunk_size, y * 32), Color(1, 0, 0), 1.0)
		for x in range(road_chunk_size/32):
			draw_line(Vector2(x * 32, 0), Vector2(x * 32, road_chunk_size/2), Color(1, 0, 0), 1.0)
			
		for pos in house_poses:
			print("pos: " + str(pos))
			draw_square(pos)
		
func draw_square(pos):
	# Norht
	draw_line(Vector2(pos.x, pos.y), Vector2(pos.x + 32, pos.y), Color(1, 0, 0), 3.0)
	# East
	draw_line(Vector2(pos.x + 32, pos.y), Vector2(pos.x + 32, pos.y + 32), Color(1, 0, 0), 3.0)
	# South
	draw_line(Vector2(pos.x, pos.y + 32), Vector2(pos.x + 32, pos.y + 32), Color(1, 0, 0), 3.0)
	# West
	draw_line(Vector2(pos.x, pos.y), Vector2(pos.x, pos.y + 32), Color(1, 0, 0), 3.0)

func _on_Timer_timeout():
#	draw = true
	update()
