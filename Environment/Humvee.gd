extends KinematicBody2D

var state = "crashed"

func _ready():
	if state == "crashed":
		get_node("Sparks").set_emitting(true)
