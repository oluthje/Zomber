extends Node2D

onready var noise = OpenSimplexNoise.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = 1
	noise.octaves = 5
	noise.period = 20.0
	noise.persistence = 0.8

	print_values()

func print_values():
	for y in range(512):
		var string = ""
		for x in range(512):
			var num = noise.get_noise_2d(x, x)
			string += str(num) + " "
		print(string)
