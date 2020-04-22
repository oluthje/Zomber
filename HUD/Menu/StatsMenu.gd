extends Node2D

var exitted = false

func _ready():
	$AnimationPlayer.play("enter")
	update_labels()

func update_labels():
	var stats_dict = get_parent().get_parent().get_saved_stats_dict()
	print("stats_dict: " + str(stats_dict))
	var stat_num_array = []
	for key in stats_dict:
		stat_num_array.append(stats_dict[key])
	
	var index = 0
	for label in get_node("StatNumLabels").get_children():
		label.set_text(str(stat_num_array[index]))
		index += 1

func _on_MenuButton_pressed():
	exitted = true
	$AnimationPlayer.play("exit")
	get_parent().get_node("AnimationPlayer").play("enter")

func _on_AnimationPlayer_animation_finished(anim_name):
	if exitted:
		queue_free()
