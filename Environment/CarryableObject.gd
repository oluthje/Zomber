extends KinematicBody2D

export var pre_set_object = ""

var object_name
var can_slide = false
var slide_to_pos = Vector2(7, 0)
var player_vel = Vector2()

func _ready():
	if pre_set_object != "":
		object_name = pre_set_object
		set_up_object(object_name, false)

func _physics_process(delta):
	if can_slide:
		var difference = global_position - slide_to_pos
		global_position = global_position.linear_interpolate(slide_to_pos, delta * 3)
		if difference.x < 0.001 and difference.y < 0.001:
			can_slide = false
			global_position = get_tree().get_root().get_node("Main").get_rounded_pos(get_global_position())
			
func set_up_object(object, slides):
	object_name = object
	can_slide = slides
	get_node("SlotItemImage").select_item_to_display(object_name)
	
	if slides:
		randomize()
		var rot_angle = rand_range(0, 360)
		slide_to_pos = slide_to_pos.rotated(deg2rad(rot_angle))
		slide_to_pos += global_position

func _on_CarryableObject_body_entered(body):
	if "Player" in body.name:
		Item.object_player_can_pick_up = object_name
		body.pickupable_object_area = self
		
func _on_CarryableObject_body_exited(body):
	if "Player" in body.name:
		Item.object_player_can_pick_up = ""
