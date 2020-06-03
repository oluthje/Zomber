extends Node2D

var open = false
var player_outside = true
var locked = false

func _physics_process(delta):
	check_if_player_interacts()
	
func set_locked(is_locked):
	if is_locked:
		locked = is_locked
		get_node("KeyLock").set_visible(true)

func check_if_player_interacts():
	var bodies = get_node("StaticBody2D/Area2D").get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name and Input.is_action_just_pressed("interact"):
			if not locked:
				if open:
					open = false
					$AnimationPlayer.play("close_outward")
				elif not open:
					open = true
					$AnimationPlayer.play("open_inward")
		elif "Player" in body.name and body.carrying_object and body.object_carrying_name == Item.KEY:
			$AnimationPlayer.play("open_inward")
			get_node("KeyLock").set_visible(false)
			locked = false
			body.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
			body.carrying_object = false
			body.object_carrying_name = ""
			body.try_update_held_item()
