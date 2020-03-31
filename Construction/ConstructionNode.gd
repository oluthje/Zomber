extends Area2D

var ConstructionSquare = preload("res://Construction/ConstructionSquare.tscn")

# Buildings
var WoodSpikes = preload("res://Obstacles/WoodenSpikes.tscn")

var draggable = true
var can_place = true
var required_materials = []
var square_array = []
var size = 2
var spacing = 16
var building_name = ""

func _ready():
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
				$AnimationPlayer.play("posfeedback")
				Item.using_menu = false
				draggable = false
			else:
				$AnimationPlayer.play("negfeedback")

func setup(building, to_be_dragged):
	building_name = building
	draggable = to_be_dragged
	if building == Item.WOOD_SPIKES:
		for i in range(4):
			required_materials.append(Item.LOG)
	
	
func can_place():
	var placeable = true
	var areas = get_overlapping_areas()
	
	for area in areas:
		if area.is_in_group("building"):
			placeable = false
			
	return placeable

func spawn_building(building):
	var building_node
	if building == Item.WOOD_SPIKES:
		building_node = WoodSpikes.instance()
	building_node.set_global_position(Vector2(get_global_position().x + 8, get_global_position().y + 8))
	get_parent().add_child(building_node)
	queue_free()

func snap_position_to_grid():
	var snap_num = 16
	var pos = get_global_position()
	set_global_position(Vector2(int(pos.x/snap_num) * snap_num + 8, int(pos.y/snap_num) * snap_num + 8))

func draw_squares():
	for x in range(size):
		for y in range(size):
			var square = ConstructionSquare.instance()
			square.set_position(Vector2(x * spacing, y * spacing))
			get_node("Squares").add_child(square)
			if square_array[x][y] == "filled":
				square.play("filledsquare")
			else:
				square.play("square")
				square.get_node("AnimationPlayer").play(square_array[x][y])

func add_resource_building(resource):
	var has_all_resources = true
	var added_resource = false
	for x in range(size):
		for y in range(size):
			if square_array[x][y] == resource and not added_resource:
				square_array[x][y] = "filled"
				added_resource = true
			if square_array[x][y] != "filled":
				has_all_resources = false
	
	if has_all_resources:
		spawn_building(building_name)
	draw_squares()

func setup_square_array():
	var index = 0
	for x in range(size):
		square_array.append([])
		square_array[x]=[]
		for y in range(size):
			square_array[x].append([])
			square_array[x][y] = required_materials[index]
			index += 1

func _on_ConstructionNode_area_entered(area):
#	if "CarryableObject" in area.name and not draggable:
#		add_resource_building(Item.LOG)
#		area.get_parent().queue_free()
	pass

func _on_ConstructionNode_body_entered(body):
	if "Player" in body.name:
		if body.carrying_object:
			add_resource_building(Item.LOG)
			body.get_node("CarryableObject").get_node("SlotItemImage").select_item_to_display("none")
			body.carrying_object = false
			body.object_carrying_name = ""
			body.try_update_held_item()
