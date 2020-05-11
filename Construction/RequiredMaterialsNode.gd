extends Node2D

var ResourceIconLabel = preload("res://HUD/ResourceIconLabel.tscn")

var show_ui_range = 128
var is_visible = true
var spacing = 25
var x_pos = -28
var resource_dict = {}

func _physics_process(delta):
	should_appear_or_disappear()

func setup(resources):
	resource_dict = resources
	draw_icons_and_labels()

func draw_icons_and_labels():
	if get_children().size() > 0:
		for child in get_children():
			if child.name != "AnimationPlayer" and child.name != "RequiredSprite":
				child.queue_free()
	
	var index = 0
	var dict_size = 0
	for resource in resource_dict:
		if resource_dict[resource] > 0:
			dict_size += 1
	if dict_size == 1:
		x_pos = -14
	for resource in resource_dict:
		if resource_dict[resource] > 0:
			spawn_material_icon(resource, Vector2(x_pos + (index*spacing), -10))
			index += 1

func should_appear_or_disappear():
	var distance_to_player = get_global_position().distance_to(get_player_pos())
	if is_visible and distance_to_player > show_ui_range:
		$AnimationPlayer.play_backwards("appear")
		is_visible = false
	elif not is_visible and distance_to_player < show_ui_range:
		$AnimationPlayer.play("appear")
		is_visible = true
		
func get_player_pos():
	var game_node
	for child in get_tree().get_root().get_node("Main").get_children():
		if "Game" in child.name:
			game_node = child
	
	return game_node.player_pos

func add_resource(resource):
	for child in get_children():
		if child.name != "AnimationPlayer" and child.name != "RequiredSprite" and child.resource == resource:
			child.reduce_required_resource()

func spawn_material_icon(icon_name, pos):
	var materials_num = resource_dict[icon_name]
	var icon = ResourceIconLabel.instance()
	icon.setup(icon_name, materials_num)
	icon.set_position(pos)
	add_child(icon)
