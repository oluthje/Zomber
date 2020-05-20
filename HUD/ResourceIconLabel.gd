extends Node2D

var resource = ""
var num_resources_required = 0

func setup(resource_name, resources_required):
	resource = resource_name
	num_resources_required = resources_required
	
	get_node("SlotItemImage").select_item_to_display(resource_name)
	get_node("Label").set_text("x" + str(num_resources_required))

func reduce_required_resource():
	num_resources_required -= 1
	$AnimationPlayer.set_speed_scale(1.25)
	$AnimationPlayer.play("label_bounce")
	get_node("Label").set_text("x" + str(num_resources_required))

func _on_AnimationPlayer_animation_finished(anim_name):
	if num_resources_required == 0:
		get_parent().draw_icons_and_labels()
		queue_free()
