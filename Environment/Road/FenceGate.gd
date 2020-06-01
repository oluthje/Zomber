extends Node2D

func _physics_process(delta):
	var bodies = get_node("Area2D").get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name:
				if body.carrying_object and body.object_carrying_name == Item.KEY:
					$AnimationPlayer.play("open")
					body.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
					body.carrying_object = false
					body.object_carrying_name = ""
					body.try_update_held_item()

func _on_HumveeDector_body_entered(body):
	if "Humvee" in body.name:
		$AnimationPlayer.play_backwards("open")
		get_node("HumveeDetector").queue_free()
