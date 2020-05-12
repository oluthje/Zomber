extends Node2D

var scroll_speed = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	$AnimationPlayer.set_speed_scale(scroll_speed)
	$AnimationPlayer.play("scroll")
	get_node("Sprite").get_node("HumveeAnimPlayer").play("drive")
	get_parent().get_node("ScrollWobblePlayer").play("wobble")
