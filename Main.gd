extends Node2D

var Game = preload("res://Game.tscn")

func _physics_process(delta):
	if Input.is_action_just_pressed("restart_game"):
		delete_game_node()
		respawn_game_node()
		
func delete_game_node():
	get_game_node().queue_free()

func get_game_node():
	for child in get_children():
		if "Game" in child.name:
			return child
	
func respawn_game_node():
	var game = Game.instance()
	add_child(game)
		
