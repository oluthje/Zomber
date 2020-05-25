extends Node2D

var ResourceIconLabel = preload("res://HUD/ResourceIconLabel.tscn")
var RequiredMatSprite = preload("res://Construction/RequiredMatSprite.tscn")

var show_ui_range = 128
var is_visible = true
var resource_dict = {}

func _physics_process(delta):
	should_appear_or_disappear()

func setup(resources):
	resource_dict = resources
	draw_icons_and_labels()
	draw_required_mat_sprites()
	print("----------------")
	var req_sprite = get_node("RequiredSprite")
	if req_sprite.get_children().size() > 0:
		for child in req_sprite.get_children():
			print("pos: " + str(child.get_position()))

func get_current_dict_size():
	var size = 0
	for resource in resource_dict:
		if resource_dict[resource] > 0:
			size += 1
			
	return size

func draw_required_mat_sprites():
	var increment = 32
	var req_sprite = get_node("RequiredSprite")
	if req_sprite.get_children().size() > 0:
		for child in req_sprite.get_children():
			child.queue_free()
	
	var total_length = get_current_dict_size()
	var start_pos_tile = (total_length - 1) * 16
	for num in range(total_length):
		spawn_reqmat_sprite(Vector2(-start_pos_tile + (num * increment), 0), 0)
	spawn_reqmat_sprite(Vector2((-start_pos_tile - (1 * increment)), 0), 2)
	spawn_reqmat_sprite(Vector2(0, 0), 1)
	spawn_reqmat_sprite(Vector2((start_pos_tile + (1 * increment)), 0), 3)

func spawn_reqmat_sprite(pos, anim_num):
	var sprite = RequiredMatSprite.instance()
	sprite.set_position(pos)
	sprite.set_frame(anim_num)
	get_node("RequiredSprite").add_child(sprite)
	
func draw_icons_and_labels():
	if get_children().size() > 0:
		for child in get_children():
			if child.name != "AnimationPlayer" and child.name != "RequiredSprite":
				child.queue_free()
	
	var dict_size = get_current_dict_size()
	var start_pos_tile = (dict_size - 1) * 16
	var increment = 32
	var index = 0
	for resource in resource_dict:
		if resource_dict[resource] > 0:
			spawn_material_icon(resource, Vector2(-start_pos_tile + (index * increment), 0))
			index += 1
			
			
#	var total_length = get_current_dict_size()
#	var start_pos_tile = (total_length - 1) * 16
#	for num in range(total_length):
#		spawn_reqmat_sprite(Vector2(-start_pos_tile + (num * increment), 0), 0)

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
