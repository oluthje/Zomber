extends StaticBody2D

var Trunk = preload("res://Environment/TreeThing.tscn")

onready var leaves_node = get_node("Leaves")
var num_logs = 4

func _ready():
#	place_logs()
	pass
	
var has_done_log_thing = 	false
func _physics_process(delta):
	if not has_done_log_thing:
		place_logs()
	
func place_logs():
	var trunk = Trunk.instance()
	get_parent().add_child(trunk)

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("blur")
	
func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("unblur")
