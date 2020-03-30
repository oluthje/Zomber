extends KinematicBody2D

export var pre_set_object = ""

var object_name
var player_vel = Vector2()

func _ready():
	if pre_set_object != "":
		object_name = pre_set_object
		set_up_object(object_name)

func set_up_object(object):
	object_name = object
	
	if object_name == Item.LOG:
		get_node("SlotItemImage").select_item_to_display(Item.LOG)

func _on_CarryableObject_body_entered(body):
	if "Player" in body.name:
		Item.object_player_can_pick_up = object_name
		body.pickupable_object_area = self
		
func _on_CarryableObject_body_exited(body):
	if "Player" in body.name:
		Item.object_player_can_pick_up = ""
