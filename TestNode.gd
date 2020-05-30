extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var first_dict = {
		"second_dict": {
			"thing": 3
		}
	}
	
	print(first_dict)
	print(first_dict["second_dict"]["thing"])
