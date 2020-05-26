extends Node2D

var chunk_pos

func _ready():
	var label = Label.new()
	label.set_text("chunk_pos: " + str(chunk_pos))
	add_child(label)

func set_road_rotation(rot):
	get_node("Road").set_rotation(deg2rad(rot))
