extends Area2D

func _on_RoofArea_body_entered(body):
	if "Player" in body.name:
		get_parent().get_node("RoofAnimPlayer").play("roof_disappear")

func _on_RoofArea_body_exited(body):
	if "Player" in body.name:
		get_parent().get_node("RoofAnimPlayer").play("roof_appear")
