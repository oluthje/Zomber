extends Node2D

var ConstructionNode = load("res://Construction/ConstructionNode.tscn")
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
		draggable_building.setup(Item.WOOD_SPIKES, true, null)
	if building == Item.TURRET:
		draggable_building.setup(Item.TURRET, true, null)
	if building == Item.STONE_WALL:
		draggable_building.setup(Item.STONE_WALL, true, null)
	
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

func _on_TurretButton_pressed():
	spawn_draggable_building(Item.TURRET)
	get_parent().start_auto_close_timer()
	Item.using_menu = true

func _on_StoneWallButton_pressed():
	spawn_draggable_building(Item.STONE_WALL)
	get_parent().start_auto_close_timer()
	Item.using_menu = true
