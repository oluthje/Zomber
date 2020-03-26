extends StaticBody2D

onready var leaves_node = get_node("Leaves")

func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("blur")
	
func _on_Area2D_body_exited(body):
	if "Player" in body.name:
		$Leaves/AnimationPlayer.play("unblur")
