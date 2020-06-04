extends Area2D

func _physics_process(delta):
	check_for_player_adding_part()

func check_for_player_adding_part():
	var bodies = get_parent().get_node("CollectPartsArea").get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name:
			if body.carrying_object and not body.in_timed_operation:
				if requires_part(body.object_carrying_name):
					if Item.COUNTDOWN_DICT.has(body.object_carrying_name):
						body.setup_obj_countdown(body.object_carrying_name, self)
						return
					add_part_after_countdown(body)

func add_part_after_countdown(player):
	get_parent().add_part(player.object_carrying_name)
	player.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
	player.carrying_object = false
	player.object_carrying_name = ""
	player.try_update_held_item()
	
func has_all_parts():
	for part in get_parent().required_materials:
		if get_parent().required_materials[part] == 1:
			return false
	return true

func requires_part(resource):
	if get_parent().required_materials.has(resource):
		if get_parent().required_materials[resource] > 0:
			return true
	return false
