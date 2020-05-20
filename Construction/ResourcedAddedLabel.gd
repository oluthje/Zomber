extends Node2D

func setup(label_text, resource):
	$AnimationPlayer.play("driftup")
	$Label.set_text(label_text)
	#$Label.get_node("SlotItemImage").select_item_to_display(resource)

func _on_Timer_timeout():
	queue_free()
