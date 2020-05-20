extends Node2D

var exitted = false

var stat_order_dict = {
	"wave_record": 0,
	"enemies_killed": 1,
	"trees_chopped": 2,
	"stone_mined": 3,
	"buildings_built": 4,
	"minutes_played:": 5
}

func _ready():
	$AnimationPlayer.play("enter")
	update_labels()

func update_labels():
	var stats_dict = get_parent().get_parent().get_saved_stats_dict()
	var stat_num_labels = get_node("StatNumLabels").get_children()
	var stat_num_label_indices = []
	
	for index in get_node("StatNumLabels").get_children().size():
		stat_num_label_indices.append(index)
	
	var index = 0
	for key in stat_order_dict:
		stat_num_labels[index].set_text(str(stats_dict[key]))
		index += 1

func _on_MenuButton_pressed():
	exitted = true
	$AnimationPlayer.play("exit")
	get_parent().get_node("AnimationPlayer").play("enter")

func _on_AnimationPlayer_animation_finished(anim_name):
	if exitted:
		queue_free()
