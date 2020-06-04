extends Node2D

var open = false
var player_outside = true
var locked = false
var required_materials = {
	Item.KEY: 1
}

func _physics_process(delta):
	check_if_player_interacts()

func add_part(part):
	$AnimationPlayer.play("open_inward")
	open = true
	get_node("KeyLock").set_visible(false)
	locked = false
	
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
#		elif "Player" in body.name and body.carrying_object and body.object_carrying_name == Item.KEY and locked:
#			$AnimationPlayer.play("open_inward")
#			open = true
#			get_node("KeyLock").set_visible(false)
#			locked = false
#			body.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
#			body.carrying_object = false
#			body.object_carrying_name = ""
#			body.try_update_held_item()
