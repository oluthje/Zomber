extends Node2D

var CarryableObject = preload("res://Environment/CarryableObject.tscn")
var locked = true

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Door").set_locked(locked)
	spawn_key()

func spawn_key():
	randomize()
	var spawn_points = get_node("LootSpawnPoints").get_children()
	var rand_num = int(rand_range(0, spawn_points.size()))
	
	var object = CarryableObject.instance()
	object.set_up_object(Item.KEY, false)
	add_child(object)
	object.set_global_position(spawn_points[rand_num].get_global_position())
	print("spawned key: " + str(spawn_points[rand_num].get_global_position()))
