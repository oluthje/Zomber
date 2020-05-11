extends Area2D

var ConstructionSquare = preload("res://Construction/ConstructionSquare.tscn")
var ResourceAddedLabel = preload("res://Construction/ResourcedAddedLabel.tscn")
var RequiredMaterialsPopup = preload("res://Construction/RequiredMaterialsNode.tscn")

# Buildings
var WoodSpikes = preload("res://Obstacles/WoodenSpikes.tscn")
var Turret = preload("res://Construction/Buildings/Turret.tscn")
var StoneWall = preload("res://Construction/Buildings/StoneWall.tscn")

var draggable = true
var can_place = true
var spacing = 16
var grid_snap_num = 16

var building_name = ""
var required_materials = {
	Item.LOG: 0,
	Item.STONE: 0
}
var total_resources = 0
var square_array = []
var size = 2

func _ready():
	total_resources = get_total_resources()
	setup_square_array()
	draw_squares()

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	if draggable:
		Item.using_menu = true
		set_global_position(mouse_pos)
		snap_position_to_grid()
		if Input.is_action_pressed("right_click"):
			Item.using_menu = false
			queue_free()
		elif Input.is_action_pressed("shoot"):
			if can_place():
				spawn_required_materials_popup()
				$AnimationPlayer.play("posfeedback")
				Item.using_menu = false
				draggable = false
			else:
				$AnimationPlayer.play("negfeedback")

func setup(building, to_be_dragged, resource_dict):
	building_name = building
	draggable = to_be_dragged
	if resource_dict == null:
		if building == Item.WOOD_SPIKES:
			required_materials[Item.LOG] = 3
		if building == Item.TURRET:
			required_materials[Item.STONE] = 2
			required_materials[Item.COMPONENT] = 1
		if building == Item.STONE_WALL:
			required_materials[Item.STONE] = 2
			grid_snap_num = 32
	else:
		required_materials = resource_dict
	if not to_be_dragged:
		spawn_required_materials_popup()
		$AnimationPlayer.play("posfeedback")

func spawn_required_materials_popup():
	var popup = RequiredMaterialsPopup.instance()
	popup.set_position(Vector2(-8, -32))
	popup.setup(required_materials)
	add_child(popup)
	
func can_place():
	var placeable = true
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("building"):
			placeable = false
	
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("building") or body.is_in_group("wall"):
			placeable = false

	return placeable

func spawn_building(building):
	var building_node
	if building == Item.WOOD_SPIKES:
		building_node = WoodSpikes.instance()
	if building == Item.TURRET:
		building_node = Turret.instance()
	if building == Item.STONE_WALL:
		building_node = StoneWall.instance()
	building_node.set_global_position(Vector2(get_global_position().x - 8, get_global_position().y - 8))
	get_parent().add_child(building_node)
	queue_free()

func snap_position_to_grid():
	var pos = get_global_position()
	if building_name == Item.STONE_WALL:
		set_global_position(Vector2(int(round(pos.x/grid_snap_num)) * grid_snap_num - 8, int(round(pos.y/grid_snap_num)) * grid_snap_num - 8))
		return
	set_global_position(Vector2(int(round(pos.x/grid_snap_num)) * grid_snap_num + 8, int(round(pos.y/grid_snap_num)) * grid_snap_num + 8))

func draw_squares():
	var percent = 0.25
	var percent_filled = get_percent_resources_filled()
	var current_num = 0
	
	if get_node("Squares").get_children().size() > 0:
		for child in get_node("Squares").get_children():
			child.queue_free()

	for x in range(size):
		for y in range(size):
			var square = ConstructionSquare.instance()
			square.set_position(Vector2(x * spacing - 16, y * spacing - 16))
			get_node("Squares").add_child(square)
			if current_num < percent_filled:
				square.play("filledsquare")
			else:
				square.play("square")
			
			current_num += percent
				
func spawn_added_resource_label():
	var label = ResourceAddedLabel.instance()
	label.setup("+", Item.LOG)
	label.set_global_position(get_global_position())
	get_parent().add_child(label)

func requires_resource(resource):
	if required_materials.has(resource):
		if required_materials[resource] > 0:
			return true
	return false
	
func add_resource_to_building(resource):
	required_materials[resource] -= 1
	$AnimationPlayer.play("posbuildfeedback")
	get_node("RequiredMaterialsNode").add_resource(resource)
	spawn_added_resource_label()
	draw_squares()
	if has_all_required_materials():
		$AnimationPlayer.play("completion_shake")

func has_all_required_materials():
	var has_all_required_materials = true
	for resource in required_materials:
		if required_materials[resource] != 0:
			has_all_required_materials = false
	
	if has_all_required_materials:
		return true
	return false

func get_total_resources():
	var resource_num = 0
	for resource in required_materials:
		resource_num += required_materials[resource]
	return resource_num

func get_percent_resources_filled():
	var resource_num = 0
	for resource in required_materials:
		resource_num += required_materials[resource]
	resource_num = total_resources - resource_num
	return float(resource_num)/float(total_resources)

func setup_square_array():
	var index = 0
	for x in range(size):
		square_array.append([])
		square_array[x]=[]
		for y in range(size):
			square_array[x].append([])
			square_array[x][y] = "unfilled"
			index += 1

func _on_ConstructionNode_body_entered(body):
	if "Player" in body.name:
		if body.carrying_object:
			if requires_resource(body.object_carrying_name):
				add_resource_to_building(body.object_carrying_name)
				body.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
				body.carrying_object = false
				body.object_carrying_name = ""
				body.try_update_held_item()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "completion_shake":
		get_parent().current_stats_dict["buildings_built"] += 1
		spawn_building(building_name)
