extends Node2D

var open = false
var player_outside = true

func _physics_process(delta):
	check_if_player_interacts()

func check_if_player_interacts():
	var bodies = get_node("StaticBody2D/Area2D").get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name and Input.is_action_just_pressed("interact"):
			print(get_player_pos_to_door(body))
			if open:
				open = false
				$AnimationPlayer.play("close_outward")
			elif not open:
				open = true
				$AnimationPlayer.play("open_inward")

func get_player_pos_to_door(body):
	var difference = get_global_position() - body.get_global_position()
	print("difference: " + str(difference))
