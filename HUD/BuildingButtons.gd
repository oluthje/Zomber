extends Node2D

var ConstructionNode = preload("res://Construction/ConstructionNode.tscn")
var anim_speed = 2

func _ready():
	show_buttons()

func show_buttons():
	$AnimationPlayer.set_speed_scale(anim_speed)
	$AnimationPlayer.play("showbuildings")
	
func hide_buttons():
	$AnimationPlayer.set_speed_scale(anim_speed)
	$AnimationPlayer.play("hidebuildings")
	
func spawn_draggable_building(building):
	var draggable_building = ConstructionNode.instance()
	if building == Item.WOOD_SPIKES:
		pass
	
	get_parent().get_parent().get_parent().add_child(draggable_building)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hidebuildings":
		queue_free()

func _on_WoodSpikesButton_pressed():
	spawn_draggable_building(Item.WOOD_SPIKES)
	get_parent().start_auto_close_timer()
	Item.using_menu = true

func _on_WoodSpikesButton_mouse_entered():
	Item.using_menu = true

func _on_WoodSpikesButton_mouse_exited():
	Item.using_menu = false
