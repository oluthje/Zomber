extends Timer

func _on_TestSpawnTimer_timeout():
	get_parent().get_node("TileMap").update_pathfinding_map()
	#spawn_zombie()

func spawn_zombie():
	var Zombie = preload("res://Enemies/Zombie/Zombie.tscn")
	var zombie = Zombie.instance()
	get_parent().add_child(zombie)
	queue_free()
